"""Rebuild the native suite from the committed, unchanged SQL order export.
Requires Python 3.11+ standard library. Power BI Desktop imports the data.
"""
import copy,csv,hashlib,json,uuid
from decimal import Decimal
from pathlib import Path
import style_report as S
from premium_design import premium
ROOT=Path(__file__).resolve().parents[1]
OL=ROOT
TEMPLATES=json.loads((ROOT/'authoring/visual-templates.json').read_text(encoding='utf-8'))
S.VISUAL_SCHEMA=TEMPLATES['card']['$schema']
def new_page(pages,title):
    pid='ReportSection'+ident(title);p=pages/pid
    save(p/'page.json',{'$schema':'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/2.1.0/schema.json','name':pid,'displayName':title,'displayOption':'FitToPage','width':1664,'height':1016})
    return p
def save(p,o): S.save(p,o)

def ident(s):return hashlib.sha256(('premium-original-'+s).encode()).hexdigest()[:20]

def field(t,n,m=False):return {'Measure' if m else 'Column':{'Expression':{'SourceRef':{'Entity':t}},'Property':n}}

def vis(page,key,kind,title,pos,roles,sort=None):
    template='barChart' if kind in ['clusteredBarChart','clusteredColumnChart','donutChart'] else kind
    o=copy.deepcopy(TEMPLATES[template]);o['name']=ident(str(page.name)+key)
    for k in ['filterConfig','filters','annotations']:o.pop(k,None)
    o['position']=dict(zip(['x','y','width','height'],pos))|{'z':10,'tabOrder':10}
    v=o['visual'];v['visualType']=kind;v.pop('filterConfig',None)
    v['query']={'queryState':{r:{'projections':[{'field':field(*f),'queryRef':f[0]+'.'+f[1],'nativeQueryRef':f[1],**({'active':True} if not f[2] and kind!='tableEx' else {})} for f in fs]} for r,fs in roles.items()}}
    if sort:v['query']['sortDefinition']={'sort':[{'field':field(*sort),'direction':'Descending'}],'isDefaultSort':False}
    v['objects']={} if kind in ['slicer','card','donutChart'] else v.get('objects',{})
    v['visualContainerObjects']['title']=[{'properties':{'show':S.lit(True),'text':S.lit(title),'fontSize':S.lit(13),'fontColor':S.fill('#24334B'),'fontFamily':S.lit('Segoe UI Semibold')}}]
    save(page/'visuals'/o['name']/'visual.json',o)

def tmdl_table(path,name,columns,source,measures=None):
    lines=['table '+name,'']
    for label,(expr,fmt) in (measures or {}).items():lines += [f"\tmeasure '{label}' = {expr}",f'\t\tformatString: {fmt}','']
    for label,typ in columns:lines += [f'\tcolumn {label}',f'\t\tdataType: {typ}','\t\tsummarizeBy: none',f'\t\tsourceColumn: {label}','']
    lines += [f'\tpartition {name} = m','\t\tmode: import','\t\tsource = '+source,'']
    path.parent.mkdir(parents=True,exist_ok=True);path.write_text('\n'.join(lines),encoding='utf-8')

def olist():
    power=OL/'powerbi';report=power/'OlistOperations.Report';model=power/'OlistOperations.SemanticModel/definition';pages=report/'definition/pages'
    source=OL/'data/processed/dashboard_orders.csv';rows=list(csv.DictReader(source.open(encoding='utf-8-sig')))
    assert len(rows)==96478 and len({r['order_id'] for r in rows})==96478
    cols=[('order_id','string'),('purchase_date','dateTime'),('purchase_year','int64'),('purchase_month','string'),('customer_state','string'),('item_count','int64'),('merchandise_cents','int64'),('delivery_eligible','int64'),('late_order','int64'),('eligible_delivery_seconds','int64'),('delivery_outcome','string'),('basket_band','string')]
    output=OL/'data/powerbi/Orders.csv';output.parent.mkdir(parents=True,exist_ok=True)
    with output.open('w',newline='',encoding='utf-8') as f:
        writer=csv.DictWriter(f,fieldnames=[x[0] for x in cols]);writer.writeheader()
        for r in rows:
            result={k:r[k] for k,_ in cols if k in r};result['merchandise_cents']=int(Decimal(r['merchandise_value'])*100)
            result['delivery_outcome']='Missing actual date' if r['delivery_eligible']=='0' else ('Late' if r['late_order']=='1' else 'On time')
            n=int(r['item_count']);result['basket_band']='1 item' if n==1 else ('2 items' if n==2 else ('3-4 items' if n<=4 else '5+ items'))
            writer.writerow(result)
    measures={
      'Delivered Orders':('COUNTROWS(Orders)','#,0'),'Merchandise Sales':('DIVIDE(SUM(Orders[merchandise_cents]),100)','#,0.00'),
      'Items':('SUM(Orders[item_count])','#,0'),'Average Order Value':('DIVIDE([Merchandise Sales],[Delivered Orders])','0.00'),
      'Eligible Deliveries':('SUM(Orders[delivery_eligible])','#,0'),'Late Orders':('SUM(Orders[late_order])','#,0'),
      'On Time Orders':('[Eligible Deliveries]-[Late Orders]','#,0'),'Late Rate':('DIVIDE([Late Orders],[Eligible Deliveries])','0.0%'),
      'Average Delivery Days':('DIVIDE(SUM(Orders[eligible_delivery_seconds]),[Eligible Deliveries]*86400)','0.00'),
      'Missing Actual Dates':('[Delivered Orders]-[Eligible Deliveries]','#,0'),'Items Per Order':('DIVIDE([Items],[Delivered Orders])','0.00'),
      'Selected Metric':('SWITCH(SELECTEDVALUE(Metric[Label],"Merchandise sales"),"Delivered orders",[Delivered Orders],"Late orders",[Late Orders],[Merchandise Sales])','#,0'),
      'Target Late Rate':('DIVIDE(SELECTEDVALUE(Target[Percent],5),100)','0.0%'),
      'Late Rate Gap':('[Late Rate]-[Target Late Rate]','+0.0%;-0.0%;0.0%'),
      'Orders Above Target':('MAX(0,[Late Orders]-[Eligible Deliveries]*[Target Late Rate])','#,0'),
      'State Sales Share':('DIVIDE([Merchandise Sales],CALCULATE([Merchandise Sales],REMOVEFILTERS(Orders[customer_state])))','0.0%'),
      'Sample Qualified Late Rate':('IF([Eligible Deliveries]>=SELECTEDVALUE(MinimumSample[Orders],100),[Late Rate])','0.0%'),
      'Selected States':('DISTINCTCOUNT(Orders[customer_state])','#,0'),
    }
    types=','.join('{"'+n+'",'+('type text' if t=='string' else 'type date' if t=='dateTime' else 'Int64.Type')+'}' for n,t in cols)
    expression='let Raw=Csv.Document(File.Contents(DataFolder & "/Orders.csv"),[Delimiter=",",Encoding=65001,QuoteStyle=QuoteStyle.Csv]), Headers=Table.PromoteHeaders(Raw,[PromoteAllScalars=true]), Typed=Table.TransformColumnTypes(Headers,{'+types+'},"en-US") in Typed'
    tmdl_table(model/'tables/Orders.tmdl','Orders',cols,expression,measures)
    for name,col,typ,values in [('Metric','Label','string',['Merchandise sales','Delivered orders','Late orders']),('Target','Percent','int64',[0,2,5,7,10,15,20]),('MinimumSample','Orders','int64',[25,100,500,1000])]:
        values=','.join('{'+('"'+str(v)+'"' if typ=='string' else str(v))+'}' for v in values)
        tmdl_table(model/'tables'/f'{name}.tmdl',name,[(col,typ)],'#table(type table ['+col+'='+('text' if typ=='string' else 'Int64.Type')+'],{'+values+'})')
    (model/'database.tmdl').write_text('database\n\tcompatibilityLevel: 1606\n')
    (model/'model.tmdl').write_text('model Model\n\tculture: en-US\n\tdefaultPowerBIDataSourceVersion: powerBI_V3\n\tsourceQueryCulture: en-US\n\tdataAccessOptions\n\t\tlegacyRedirects\n\t\treturnErrorValuesAsNull\n\nannotation __PBI_TimeIntelligenceEnabled = 0\n\n'+''.join('ref table '+n+'\n' for n in ['Orders','Metric','Target','MinimumSample']))
    (model/'expressions.tmdl').write_text('expression DataFolder = "'+str(output.parent)+'" meta [IsParameterQuery=true,Type="Text",IsParameterQueryRequired=true]\n')
    (model/'relationships.tmdl').write_text('')
    save(power/'OlistOperations.SemanticModel/definition.pbism',{'version':'4.2','settings':{}})
    save(report/'definition.pbir',{'version':'4.0','datasetReference':{'byPath':{'path':'../OlistOperations.SemanticModel'}}})
    save(power/'OlistOperations.pbip',{'version':'1.0','artifacts':[{'report':{'path':'OlistOperations.Report'}}],'settings':{'enableAutoRecovery':True}})
    save(report/'definition/report.json',json.loads((OL/'authoring/report-template.json').read_text(encoding='utf-8')))
    specs=[
      ('Commerce overview',[('Metric','Label','Chart metric | default sales')],['Merchandise Sales','Delivered Orders','Average Order Value','Items Per Order'],
       [('lineChart','Historical demand | incomplete boundary months retained','purchase_month',['Selected Metric']),( 'barChart','State contribution | click to focus','customer_state',['Selected Metric'])],['customer_state','Merchandise Sales','Delivered Orders','Average Order Value','State Sales Share']),
      ('Delivery watch',[('Target','Percent','Late-rate target % | default 5')],['Eligible Deliveries','Late Orders','Late Rate','Orders Above Target'],
       [('lineChart','Late rate against selected target | descriptive gap','purchase_month',['Late Rate','Target Late Rate']),('donutChart','Delivery outcomes | includes eight missing dates','delivery_outcome',['Delivered Orders'])],['purchase_month','Eligible Deliveries','Late Orders','Late Rate','Average Delivery Days','Missing Actual Dates']),
      ('State explorer',[('MinimumSample','Orders','Minimum eligible orders | default 100')],['Selected States','Merchandise Sales','Late Rate','Average Delivery Days'],
       [('barChart','Late rate | states below minimum sample hidden','customer_state',['Sample Qualified Late Rate']),('barChart','Merchandise sales by destination state','customer_state',['Merchandise Sales'])],['customer_state','Eligible Deliveries','Late Orders','Late Rate','Average Delivery Days','State Sales Share']),
      ('Basket economics',[('Orders','basket_band','Basket size')],['Items','Delivered Orders','Average Order Value','Items Per Order'],
       [('clusteredColumnChart','Order volume by basket size','basket_band',['Delivered Orders']),('barChart','Average order value by basket size','basket_band',['Average Order Value'])],['basket_band','Delivered Orders','Items','Merchandise Sales','Average Order Value','Late Rate']),
      ('Order explorer',[('Orders','delivery_outcome','Delivery outcome')],['Delivered Orders','Eligible Deliveries','Late Orders','Missing Actual Dates'],
       [('barChart','Selected orders by destination','customer_state',['Delivered Orders']),('lineChart','Selected orders by purchase month','purchase_month',['Delivered Orders'])],['order_id','purchase_date','customer_state','basket_band','delivery_outcome','merchandise_cents','eligible_delivery_seconds']),
    ]
    pids=[]
    for title,extra,cards,charts,details in specs:
        p=new_page(pages,title);pids.append(p.name)
        controls=[('Orders','purchase_year','Purchase year'),('Orders','purchase_month','Purchase month'),('Orders','customer_state','Destination state')]+extra
        for i,(t,c,label) in enumerate(controls):vis(p,'s'+str(i),'slicer',label,(248+i*352,116,336,80),{'Values':[(t,c,False)]})
        for i,m in enumerate(cards):vis(p,'k'+str(i),'card',m,(248+i*352,208,336,106),{'Values':[('Orders',m,True)]})
        for i,(kind,label,cat,ms) in enumerate(charts):vis(p,'c'+str(i),kind,label,(248+i*704,334,688,300),{'Category':[('Orders',cat,False)],'Y':[('Orders',m,True) for m in ms]},sort=None if kind in ['lineChart','donutChart'] else ('Orders',ms[0],True))
        vis(p,'details','tableEx','Order evidence | cents and seconds are labelled source units' if title=='Order explorer' else 'Supporting evidence | ratios recompute in the current selection',(248,654,1392,310),{'Values':[('Orders',c,c in measures) for c in details]})
    save(pages/'pages.json',{'$schema':'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/pagesMetadata/1.1.0/schema.json','pageOrder':pids,'activePageName':pids[0]})
    premium(report,'OLIST\nOPERATIONS','#BFA4FF','#52CDB1','#241F3D','PUBLIC OLIST DATA\nHistorical 2016–2018\nDelivered orders only',{
      'Commerce overview':'Merchandise value excludes freight. Switch the chart metric; select a state or month to focus the evidence.',
      'Delivery watch':'Target is an adjustable benchmark, not a forecast. Late rate uses eligible deliveries; missing dates stay visible.',
      'State explorer':'Compare destination states with a minimum-sample guard. Rates are descriptive; sales are not profit.',
      'Basket economics':'Order-level basket sizes. This source does not contain product cost or allocated profit.',
      'Order explorer':'Use filters to find the underlying order IDs. Raw money is integer cents; elapsed delivery time is seconds.'})
    manifest={'source':str(source.relative_to(OL)),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'orders':len(rows),'eligible':sum(int(r['delivery_eligible']) for r in rows),'late':sum(int(r['late_order']) for r in rows),'merchandise_cents':sum(int(Decimal(r['merchandise_value'])*100) for r in rows),'items':sum(int(r['item_count']) for r in rows),'pages':len(specs),'measures':len(measures)}
    save(OL/'docs/build-validation.json',manifest)
    save(report/'definition/version.json',{'$schema':'https://developer.microsoft.com/json-schemas/fabric/item/report/definition/versionMetadata/1.0.0/schema.json','version':'2.0.0'})
    for folder,kind in [('OlistOperations.Report','Report'),('OlistOperations.SemanticModel','SemanticModel')]:
        platform=power/folder/'.platform'
        if not platform.exists():save(platform,{'$schema':'https://developer.microsoft.com/json-schemas/fabric/gitIntegration/platformProperties/2.0.0/schema.json','metadata':{'type':kind,'displayName':'Olist Operations'},'config':{'version':'2.0','logicalId':str(uuid.uuid5(uuid.NAMESPACE_URL,'vaishnavi05-byte/ecommerce-sales-analysis/'+kind))}})
    for path,schema in [(power/'OlistOperations.pbip','https://developer.microsoft.com/json-schemas/fabric/pbip/pbipProperties/1.0.0/schema.json'),(report/'definition.pbir','https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json')]:
        value=json.loads(path.read_text(encoding='utf-8'));value['$schema']=schema;save(path,value)
    (OL/'.gitignore').write_text('__pycache__/\n*.pyc\ntmp/\npowerbi/**/.pbi/\n*.log\n')
    print('Olist:',json.dumps(manifest))

if __name__=="__main__":olist()
