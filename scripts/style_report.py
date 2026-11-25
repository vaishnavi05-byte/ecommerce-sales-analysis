"""Apply the original Decision Studio visual system to native PBIR source.

Native data roles are retained. Run after building pages, before Desktop reload.
"""
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
REPORT=ROOT/'powerbi/DecisionStudio.Report'
DEF=REPORT/'definition'


def save(path,value):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(value,indent=2),encoding='utf-8')


def lit(value):
    if isinstance(value,bool): v=str(value).lower()
    elif isinstance(value,str): v="'"+value.replace("'","''")+"'"
    else: v=str(value)+'D'
    return {'expr':{'Literal':{'Value':v}}}


def fill(value):return {'solid':{'color':lit(value)}}


def oid(value):return hashlib.sha256(('ds-design-'+value).encode()).hexdigest()[:20]


def vco(bg=False, color='#FFFFFF'):
    return {'background':[{'properties':{'show':lit(bg),'color':fill(color),'transparency':lit(0)}}],
            'border':[{'properties':{'show':lit(False)}}],
            'visualHeader':[{'properties':{'show':lit(False)}}],
            'padding':[{'properties':{side:lit(0) for side in ['top','bottom','left','right']}}]}


def textbox(page,key,text,x,y,w,h,size=16,fg='#173243',bg=None,bold=False):
    name=oid(page.name+'-'+key)
    paragraphs=[{'textRuns':[{'value':line,'textStyle':{'fontFamily':'Segoe UI Semibold' if bold else 'Segoe UI','fontSize':str(size)+'px','color':fg}}],
                 'horizontalTextAlignment':'left'} for line in text.split('\n')]
    obj={'$schema':VISUAL_SCHEMA,'name':name,'position':{'x':x,'y':y,'width':w,'height':h,'z':0 if key=='sidebar' else 10000,'tabOrder':900},
         'visual':{'visualType':'textbox','objects':{'general':[{'properties':{'paragraphs':paragraphs}}]},
                   'visualContainerObjects':vco(bg is not None,bg or '#FFFFFF')},
         'annotations':[{'name':'DecisionStudioChrome','value':'true'}]}
    save(page/'visuals'/name/'visual.json',obj)


def button(page,key,label,action,x,y,w=184,h=48,target=None,active=False):
    name=oid(page.name+'-'+key)
    link={'show':lit(True),'type':lit(action)}
    if target:link['navigationSection']=lit(target)
    obj={'$schema':VISUAL_SCHEMA,'name':name,'position':{'x':x,'y':y,'width':w,'height':h,'z':10100,'tabOrder':950},
         'howCreated':'InsertVisualButton',
         'visual':{'visualType':'actionButton','drillFilterOtherVisuals':True,
                   'objects':{
                     'text':[{'properties':{'show':lit(True)}},{'selector':{'id':'default'},'properties':{'text':lit(label),'fontSize':lit(12),'fontFamily':lit('Segoe UI Semibold'),'fontColor':fill('#FFFFFF'),'horizontalAlignment':lit('left'),'verticalAlignment':lit('middle'),'leftMargin':lit(14),'rightMargin':lit(10),'topMargin':lit(0),'bottomMargin':lit(0)}}],
                     'fill':[{'properties':{'show':lit(True)}},{'selector':{'id':'default'},'properties':{'fillColor':fill('#087F8C' if active else '#223F51'),'transparency':lit(0)}},{'selector':{'id':'hover'},'properties':{'fillColor':fill('#146878'),'transparency':lit(0)}}],
                     'outline':[{'properties':{'show':lit(False)}}],
                     'icon':[{'properties':{'show':lit(False)}}],
                     'shape':[{'properties':{'tileShape':lit('rectangleRounded'),'roundEdge':lit(8)}},{'selector':{'id':'default'},'properties':{'tileShape':lit('rectangleRounded')}}]},
                   'visualContainerObjects':{**vco(),'visualLink':[{'properties':link}]}},
         'annotations':[{'name':'DecisionStudioChrome','value':'true'}]}
    save(page/'visuals'/name/'visual.json',obj)


