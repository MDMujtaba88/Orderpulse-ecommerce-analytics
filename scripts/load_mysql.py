"""Load only generated portfolio tables. Password is prompted, never saved."""
from pathlib import Path
from getpass import getpass
import argparse
import pandas as pd
from sqlalchemy import create_engine, text, String, Date, DateTime, Numeric, BigInteger, Float
from sqlalchemy.engine import URL

ROOT = Path(__file__).resolve().parents[1]
TABLES = {
    'fact_orders':['order_id'],
    'fact_order_items':['order_id','order_item_id'],
    'dim_customer':['customer_id'],
    'dim_product':['product_id'],
    'dim_seller':['seller_id'],
    'dim_date':['date'],
}


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--host', default='localhost')
    p.add_argument('--user', default='root')
    p.add_argument('--replace', action='store_true', help='Rebuild these six generated tables in orderpulse_portfolio.')
    args = p.parse_args()
    url = URL.create('mysql+pymysql', username=args.user, password=getpass('MySQL password: '), host=args.host, database='orderpulse_portfolio')
    engine = create_engine(url)
    for name, keys in TABLES.items():
        df = pd.read_csv(ROOT/'data/processed'/f'{name}.csv', dtype={c:'string' for c in ['order_id','customer_id','customer_unique_id','seller_id','product_id']})
        types = {}
        for c in df:
            if c in ['date','purchase_date']:
                df[c] = pd.to_datetime(df[c]); types[c] = Date()
            elif c.endswith(('_timestamp','_date','_at')):
                df[c] = pd.to_datetime(df[c]); types[c] = DateTime()
            elif c in ['price','item_value','freight_value','payment_value','payment_item_gap']:
                types[c] = Numeric(16,2)
            elif pd.api.types.is_integer_dtype(df[c]):
                types[c] = BigInteger()
            elif pd.api.types.is_numeric_dtype(df[c]):
                types[c] = Float()
            else:
                types[c] = String(255)
        for c in keys:
            if c.endswith('_id') and c != 'order_item_id':
                types[c] = String(32)
        df.to_sql(name,engine,index=False,if_exists='replace' if args.replace else 'fail',dtype=types,chunksize=2000)
        key_sql = ','.join(f'`{k}`' for k in keys)
        with engine.begin() as conn:
            conn.execute(text(f'ALTER TABLE `{name}` ADD PRIMARY KEY ({key_sql})'))
        print(f'{name}: {len(df):,} rows loaded')
    engine.dispose()


if __name__ == '__main__':
    main()
