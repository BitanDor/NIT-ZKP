This folder contains the toy demos of BitTorrent we used in our project and their supporting tools. 
All files should be modified before use to include correct references to local folders instead of those that appear here.
The Jupyter Notebook file (build virtual BitTorrent network.ipynb) is used for constructing the virtual network. 
To use it, you should first have several movies in a designated folder. 
BitTorrent_Demo.py is the non modified version of our toy demo. 
BitTorrent_Demo_LE_version.py is the modified version that enables the client to download all pieces from the same user. 
Both versions use the file client_request.py as a socket component. 
Before running the demos, one should wake up the virtual network into life by running Set_Virtual_Network.py. 
