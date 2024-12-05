#import libraries
#!pip install kaggle
#import kaggle
import kaggle
!kaggle datasets download ankitbansal06/retail-orders -f orders.csv

#extract file from zip file
import zipfile
zip_ref = zipfile.ZipFile('orders.csv.zip') 
zip_ref.extractall() # extract file to dir
zip_ref.close() # close file

#read data from the file and handle null values
import pandas as pd
df = pd.read_csv('orders.csv',na_values=['Not Available','unknown'])
df['Ship Mode'].unique()

#rename columns names ..make them lower case and replace space with underscore
df.rename(columns={'Order Id':'order_id', 'City':'city'})
df.columns=df.columns.str.lower()
df.columns=df.columns.str.replace(' ','_')
df.head(5)

#derive new columns discount , sale price and profit
df['discount']=df['list_price']*df['discount_percent']*.01
df['sale_price']= df['list_price']-df['discount']
df['profit']=df['sale_price']-df['cost_price']
df.head()


#convert order date from object data type to datetime
df['order_date']=pd.to_datetime(df['order_date'],format="%Y-%m-%d")


#drop cost price list price and discount percent columns
df.drop(columns=['list_price','cost_price','discount_percent'],inplace=True)


#load the data into sql server using replace option
import sqlalchemy as sal
import os
from dotenv import load_dotenv
#import psycopg2 (if installed in the enviornment SQLAlchemy uses it "under the hood" and not directly)

# Load environment variables from .env file
load_dotenv('.env')

# Retrieve the database credentials from environment variables
db_username = os.getenv('DB_USERNAME')
db_password = os.getenv('DB_PASSWORD')
db_name = os.getenv('DB_NAME')
db_host = os.getenv('DB_HOST')
db_port = os.getenv('DB_PORT')

# Step 3: Create the PostgreSQL connection string using the credentials
connection_string = f'postgresql://{db_username}:{db_password}@{db_host}:{db_port}/{db_name}'

# Step 4: Create SQLAlchemy engine using the connection string
engine = sal.create_engine(connection_string)

# Step 5: Establish connection
conn = engine.connect()

df.to_sql('df_orders', con=engine, if_exists='append', index=False)

print("Data loaded successfully into PostgreSQL!")