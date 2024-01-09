import os
import requests
import zipfile

# -----------------------------------------------------------------------------

data_dir = './data'

# -----------------------------------------------------------------------------

def get_file_path(file_name: str, check_exist: bool = False) -> str:
    '''
    returns full file path to 'file_name' (stored inside of 'data_dir'), also
    checks existance depending on 'check_exist' and returns '' on fail
    '''
    file_path = os.path.join(data_dir, file_name)
    if not check_exist or os.path.isfile(file_path):
        return file_path
    else:
        return ''

def download_file(url: str, file_name: str = '') -> str:
    '''
    downloads 'url' and stores it as 'file_name' (or one extracted from url)
    into 'data_dir'; returns 'file_name' after successful save, '' otherwise
    '''
    # obtain 'file_name' from 'url', if not given
    if file_name == '': file_name = os.path.basename(url)
    # create full path to file
    file_path = get_file_path(file_name)
    # test and recieve file from 'url', store as 'file_name'
    try:
        response = requests.head(url)
        if response.status_code != 200:
            print('ERROR! url request failed with:', response.status_code)
            return ''
        else:
            response = requests.get(url, allow_redirects=True, stream=True)
            with open(file_path, mode='wb') as file:
                for chunk in response.iter_content(chunk_size=1024 * 1024):
                    file.write(chunk)
            print('+ file downloaded:', file_name)
            return file_name
    except Exception as e:
        print('ERROR! download failed:', e)
        return ''

def unzip_file(file_name: str) -> list[str]:
    '''
    unzips all contents of 'file_name' (stored inside of 'data_dir') into its
    parent directory; returns list of extracted files or '[]' on fail
    '''
    # create full path to file, ensure it exists
    file_path = get_file_path(file_name, check_exist=True)
    if not file_path:
        print('ERROR! file does not exist:', file_path)
        return []
    # extract all file contents to parent directory
    try:
        with zipfile.ZipFile(file_path, 'r') as zip_file:
            zip_file_contents = zip_file.namelist()
            zip_file.extractall(os.path.dirname(file_path))
            print('+ files extracted:', zip_file_contents)
            return zip_file_contents
    except zipfile.BadZipFile:
        print('ERROR! not a zip or a corrupted zip file')
        return []
