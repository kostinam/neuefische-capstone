import os
import pandas
import sqlalchemy
import psycopg2

from sqlalchemy.engine.base import Engine
from dotenv import dotenv_values

# -----------------------------------------------------------------------------

env_file = './.env'

# -----------------------------------------------------------------------------

def get_sql_config(
) -> dict:
    '''
    loads credentials and parameters from 'env_file'; returns a dictionary
    containing those needed further on, False otherwise
    '''
    # check if 'env_file' exists
    if not os.path.isfile(env_file):
        print('ERROR! file does not exist:', env_file)
        return False
    else:
        needed_keys = [
              'host'
            , 'port'
            , 'database'
            , 'user'
            , 'password'
            , 'options'
        ]
        dotenv_dict = dotenv_values(env_file)
        return {
            key: dotenv_dict[key] for key in needed_keys if key in dotenv_dict
        }

def get_engine(
) -> Engine:
    '''
    returns sqlalchemy connection engine for the PostgreSQL database
    (configured via 'env_file'); error handling is omitted
    '''
    return sqlalchemy.create_engine(
          'postgresql://user:pass@host/database'
        , connect_args=get_sql_config()
    )

def run_command(
    sql_command: str
) -> None:
    '''
    runs the given command on the PostgreSQL database (configured via
    'env_file'); return & error handling is omitted
    '''
    with get_engine().begin() as connection:
        connection.execute(sql_command)

def get_data(
    sql_query: str
) -> list:
    '''
    returns the result as a list after running sql_query on the PostgreSQL
    database (configured via 'env_file'); error handling is omitted
    '''
    with get_engine().begin() as connection:
        return connection.execute(sql_query).fetchall()

def get_dataframe(
    sql_query: str
) -> pandas.DataFrame:
    '''
    returns the result as a pandas dataframe after running sql_query on the
    PostgreSQL database (configured via 'env_file'); error handling is omitted
    '''
    return pandas.read_sql_query(sql=sql_query, con=get_engine())

def write_dataframe(
      dataframe: pandas.DataFrame
    , table: str
    , mode: str = 'replace'
    , index: bool = False
) -> None:
    '''
    writes the given pandas dataframe to the PostgreSQL database (configured
    via 'env_file')
    '''
    try:
        dataframe.to_sql(
              name = table
            , if_exists = mode
            , index = index
            , con = get_engine()
            , chunksize = 5000
            , method = 'multi'
        )
        print('+ table written:', table)
    except (Exception, psycopg2.DatabaseError) as e:
        print('ERROR! table write failed:', e)
