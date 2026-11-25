"""Independently reconcile saved actual Power BI DAX results to SQL CSV export."""
import csv,json,math
from decimal import Decimal
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
rows=list(csv.DictReader((ROOT/'data/processed/dashboard_orders.csv').open(encoding='utf-8-sig')))
actual=json.loads((ROOT/'docs/native-dax-results.json').read_text(encoding='utf-8-sig'))
checks=0
def metrics(group,target=.05):
    n=len(group);sales=sum(Decimal(r['merchandise_value']) for r in group);eligible=sum(int(r['delivery_eligible']) for r in group);late=sum(int(r['late_order']) for r in group);items=sum(int(r['item_count']) for r in group)
    return dict(Orders=n,Sales=float(sales),Items=items,Eligible=eligible,Late=late,Missing=n-eligible,Days=sum(int(r['eligible_delivery_seconds']) for r in group)/eligible/86400 if eligible else None,AOV=float(sales)/n if n else None,Units=items/n if n else None,LateRate=late/eligible if eligible else None,GapOrders=max(0,late-eligible*target))
def compare(row,expected):
    global checks
    for k,v in expected.items():
        if '['+k+']' not in row:continue
        a=row['['+k+']']
        assert (a is None and v is None) or (a is not None and v is not None and math.isclose(a,v,rel_tol=1e-10,abs_tol=1e-6)),(k,a,v)
        checks+=1
compare(actual[0]['rows'][0],metrics(rows))
def band(r):
    n=int(r['item_count']);return '1 item' if n==1 else '2 items' if n==2 else '3-4 items' if n<=4 else '5+ items'
for index,key in [(1,'customer_state'),(2,'purchase_month'),(3,'basket_band')]:
    values={band(r) if key=='basket_band' else r[key] for r in rows}
    assert {r['Orders['+key+']'] for r in actual[index]['rows']}==values
    for a in actual[index]['rows']:
        value=a['Orders['+key+']'];group=[r for r in rows if (band(r) if key=='basket_band' else r[key])==value];compare(a,metrics(group))
compare(actual[4]['rows'][0],metrics([r for r in rows if r['customer_state']=='SP'],.10))
qualified={s for s in {r['customer_state'] for r in rows} if sum(int(r['delivery_eligible']) for r in rows if r['customer_state']==s)>=1000}
assert {r['Orders[customer_state]'] for r in actual[5]['rows']}==qualified
for a in actual[5]['rows']:
    e=metrics([r for r in rows if r['customer_state']==a['Orders[customer_state]']])['LateRate'];assert math.isclose(a['[Rate]'],e,abs_tol=1e-12);checks+=1
result={'result':'PASS','numeric_comparisons':checks,'source_orders':len(rows),'source_grain':'one delivered order','actual_engine':'Power BI Desktop local model; saved DAX result sets','scopes':['total','27 states','purchase months','basket bands','SP with 10% target','minimum-sample guard']}
(ROOT/'docs/native-validation.json').write_text(json.dumps(result,indent=2))
print(json.dumps(result,indent=2))
