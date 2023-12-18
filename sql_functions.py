# We import a method from the  modules to address environment variables and 
# we use that method in a function that will return the variables we need from
# .env to a dictionary we call sql_config

from dotenv import dotenv_values

def get_sql_config():
    '''
        loads credentials and parameters from .env file and returns a
        dictionary containing those needed for sqlalchemy.create_engine()
    '''
    needed_keys = [
          'host'
        , 'port'
        , 'database'
        , 'user'
        , 'password'
        , 'options'
    ]
    dotenv_dict = dotenv_values(".env")
    sql_config = {
        key: dotenv_dict[key] for key in needed_keys if key in dotenv_dict
    }
    return sql_config

# import sqlalchemy and pandas
import sqlalchemy
import pandas as pd


# functions
# =============================================================================

def get_data(sql_query):
   '''
   connect to PostgreSQL database, run query and return result as a list
   '''
   # get the connection configuration dictionary using get_sql_config function
   sql_config = get_sql_config()
   # create a connection engine to the PostgreSQL server
   engine = sqlalchemy.create_engine(
        'postgresql://user:pass@host/database'
      , connect_args=sql_config
   )
   # open conn session using 'with', execute the query, and return the results
   with engine.begin() as conn: 
      results = conn.execute(sql_query)
      return results.fetchall()

def get_dataframe(sql_query):
    ''' 
    connect to PostgreSQL database, run query and return result as a dataframe
    '''
    # get the connection configuration dictionary using get_sql_config function
    sql_config = get_sql_config()
    # create a connection engine to the PostgreSQL server
    engine = sqlalchemy.create_engine(
          'postgresql://user:pass@host/database'
        , connect_args=sql_config
    )
    # return query result as DataFrame
    return pd.read_sql_query(sql=sql_query, con=engine)

# function to create sqlalchemy engine for writing data to a database
def get_engine():
    ''' 
    connect to PostgreSQL database and return engine/connection,
    e.g. for usage in toSQL()
    '''
    sql_config = get_sql_config()
    engine = sqlalchemy.create_engine(
          'postgresql://user:pass@host/database'
        , connect_args=sql_config
    )
    return engine
