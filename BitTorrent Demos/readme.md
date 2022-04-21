This folder contains the toy demos of BitTorrent we used in our project and their supporting tools. 


_build virtual BitTorrent network.ipynb_ (Jupyter Notebook file) is used for constructing the virtual network. 

To use it, you should first have several movies in a designated folder. 


_BitTorrent_Demo.py_ is the non modified version of our toy demo. 

_BitTorrent_Demo_LE_version.py_ is the modified version that enables the client to download all pieces from the same user. 

Both versions use the file _client_request.py_ as a socket component. 

Before running the demos, one should wake up the virtual network into life by running _Set_Virtual_Network.py_. 


## Please note

All files should be modified before use to include references to local folders instead of those that currently appear.
