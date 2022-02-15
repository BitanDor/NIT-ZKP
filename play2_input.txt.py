import PySimpleGUI as sg
import random
import glob
import os
import hashlib
import json
from datetime import datetime
def root_hash(lst):
    n=len(lst)
    if n==1:
        return lst[0]
    if n==2:
        m = hashlib.sha256()
        m.update(lst[0])
        m.update(lst[1])
        return m.digest()
    k=int((n+1)/2)
    return root_hash([
        root_hash(lst[:k]), root_hash(lst[k:])])
def hash_bytes(s):
    if type(s) == bytes:
        m = hashlib.sha256()
        m.update(s)
        return m.digest()
    else:
        if type(s) == list:
            return [hash_bytes(element) for element in s]
        else:
            return hash_bytes(
                bytes(str(s).encode()))
def ip2port(ip_string):
    number_strings = ip_string.split(".")
    nums = [int(e) for e in number_strings]
    return (7*nums[0] + 11*nums[1] + 13*nums[2] + 19*nums[3] +
            2*nums[1] * nums[3] + 3*nums[0] * nums[2])%60000 + 5000
def name(L):
    return L[::-1][4 : L[::-1].index('\\')][::-1]
def piece_name(s):
    return s[::-1][:s[::-1].index('\\')][::-1]
def parse_piece(x):
    num = x[::-1][:x[::-1].index('_')][::-1]
    return x[:-len(num)-8], int(num)
def build_file(directory):
    pieces_locations = glob.glob(directory + os.sep + "**")
    file_name = piece_name( pieces_locations[0] )[:-10]
    with open(directory + os.sep + file_name + ".mp4", "wb") as out_file:
        for in_piece in pieces_locations:
            with open(in_piece, "rb") as temp_piece_file:
                data = temp_piece_file.read()
                out_file.write(data)
    return
def enter_download_mode():
    window["Download"].update(visible = False)
    window['BAR'].update(0, visible = True)
    window['BAR_TEXT'].update("Download progress:", visible = True)
    return
def create_target_directory( mov_name ):
    download_time = str( datetime.now() )[:-7].replace(" ", "__").replace(":", "_")
    os.mkdir( client_dir + os.sep + mov_name + "___" + download_time)
    summary_string = "##### Summary File For Movie Download From Network #####\n\n"
    summary_string += f"Downloading movie: {mov_name}.\n"
    summary_string += f"Download initiated on: {download_time}.\n\n"
    summary_string += "Providers of pieces:\n"
    return summary_string, download_time
def download_n_display_summary( mov_name, pieces_providers,torr):
    enter_download_mode()
    summary_string, download_time = create_target_directory( mov_name )
    NumOfPieces = len(pieces_providers)
    for i, user_ip in enumerate( pieces_providers ):
        param_string = f"{ip2port(user_ip)} {mov_name} {i} {client_dir + os.sep + mov_name+'___'+download_time}"
        os.system(f"python client_request.py {param_string}")
        summary_string += f"Piece: {' '*(2-len(str(i))) + str(i)}; Provider virtual IP: {user_ip}; Provider port: {ip2port(user_ip)}.\n"
        window['BAR'].update( 100 * (i / (NumOfPieces + 1)), visible = True)
        window['BAR_TEXT'].update(f"Download progress: {round(100 * (i / (NumOfPieces + 1)), 1)}%", visible = True)
    hash_check_list = []
    X = glob.glob( client_dir + os.sep + mov_name + "___" + download_time + os.sep + '**')
    for piece_loc in X:
        with open(piece_loc, "rb") as curr_piece:
            piece_bytes = curr_piece.read()
            hash_check_list.append( hash_bytes(piece_bytes) )
    summary_string += f"\n\nRoot hash of downloaded files: {root_hash(hash_check_list).hex()}\n"
    summary_string += f"Root hash appeared in torrent file: {torr['root hash of file']}\n"
    if root_hash( hash_check_list ).hex() == torr[ 'root hash of file' ]:
        summary_string += "\nHash check successful! Files are authentic."
        build_file( client_dir + os.sep + mov_name + "___" + download_time)
        window["MESSAGE"].update( "Successfully downloaded following movie.\n Summary file saved.\nYour movie is ready -- mp4 file was built from pieces. Enjoy!", text_color = "white", font = ("Arial", 15))
    else:
        summary_string +="\nHash check failed. Files are NOT authentic."
        window["MESSAGE"].update( "Following movie was downloaded BUT HASH CHECK FAILED!\nMovie was NOT built from pieces. \nSummary file saved.", text_color = "white", font = ("Arial", 15))
    summary_file_loc = client_dir + os.sep + mov_name + "___" + download_time + os.sep + mov_name + "__Summary_File.txt"
    with open( summary_file_loc, "w" ) as summary_file:
        summary_file.write( summary_string )
    window['BAR'].update(100, visible = True)
    window['BAR_TEXT'].update( "Download complete.", visible=True)
    return
def set_internet_connection():
    home = r'C:\Users\bitan\scripts'
    return home + os.sep + 'code' +os.sep + r'Virtual_Network\torrents', home + os.sep + r'code\Virtual_Network\Users'
def set_local_environment():
    home = r'C:\Users\bitan\scripts'
    return home + os.sep + r'code\Virtual_Network\Client'
def set_layout():
    lay = [[sg.Text( "Wellcome to BitTorrent Demo", font = ("Arial", 18))],
           [sg.Text( "What movie would you like to download from the P2P network today?")],
           [sg.Input( key = 'INPUT', size=(50,15)), sg.Button("Search", key='SEARCH_BUTTON')],
           [sg.Text("Message for user about requested movie", key="MESSAGE", visible=False)],
           [sg.Text("Found_torrent", key = "TORRENT", visible=False)],
           [sg.Button("Download", visible = False)],
           [sg.Text("Download progress:", key='BAR_TEXT', visible=False)],
           [sg.ProgressBar(100, size=(20,20), key='BAR',bar_color = ("green", "white"), visible=False )],
           [sg.Button("Exit")]]
    return lay
def present_not_found_message( wanted_movie ):
    window['INPUT'].update("")
    window["TORRENT"].update("", visible = False)
    window["Download"].update(visible = False)
    window['BAR'].update(0, visible = False)
    window['BAR_TEXT'].update("Download progress:", visible = False)
    window["MESSAGE"].update(f"Requested movie was not found: {wanted_movie}", text_color = "red", font = ("Arial", 13), visible = True)
    return
def disp_torrent_to_download( wanted_movie ):
    window['BAR'].update(0, visible = False)
    window['BAR_TEXT'].update( "Download progress:", visible = False)
    wanted_torrtent_loc = torrents_location + os.sep + wanted_movie + "_torrent.txt"
    with open(wanted_torrtent_loc) as json_file:
        current_torrent = json.load(json_file)
    window["MESSAGE"].update( "Found following torrent for movie:", text_color = "white", font = ("Arial", 13), visible = True)
    displayed_torrent = "Results:\n"
    for item in ['file name', 'Announce', 'ip of seeder', 'file length in bytes', 'piece length in bytes', 'number of pieces', 'root hash of file']:
        displayed_torrent = displayed_torrent + item + ": " + str( current_torrent[item] ) + "\n"
    window["TORRENT"].update( displayed_torrent, visible=True)
    window["Download"].update( visible = True)
    return current_torrent
def generate_providers_list( nodes ):
    intersection = [element for element in nodes[0]]
    for temp_list in nodes:
        intersection = list(set(intersection) & set(temp_list))
    provider = random.sample(intersection,1)[0]
    res = [provider for i in range(len(nodes))]
    return res
torrents_location, users_location = set_internet_connection()
client_dir = set_local_environment()
sg.theme('Topanga')
layout = set_layout()
window = sg.Window(title="BT Demo", layout = layout, margins=(50, 50), size=(800, 600))
while True:
    event, values = window.read()
    if event == "Exit" or event == sg.WIN_CLOSED:
        break
    if event == "SEARCH_BUTTON":
        wanted_movie = values['INPUT']
        requested_torrent_location = torrents_location+os.sep + wanted_movie + "_torrent.txt"
        if requested_torrent_location in glob.glob(torrents_location + os.sep + "**"):
            requested_torrent = disp_torrent_to_download( wanted_movie )
        else:
            present_not_found_message( wanted_movie )
    if event == "Download":
        pieces_providers = generate_providers_list( requested_torrent['nodes'] )
        download_n_display_summary( wanted_movie, pieces_providers, requested_torrent)
window.close()
