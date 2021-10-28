from datetime import *
import random 
import string
import asyncio
import websockets
import sys

# https://limecoda.com/how-to-build-basic-websocket-server-python/
print("Running Server...")
server_id = "XSERVERX"
MAX_MESSAGES = 80
msg_list = []

async def server(websocket, path):
    my_msg_id_list = []
    print("User joined")
    # Get received data from websocket
    try:
        while(True):
            data = await websocket.recv()
            print("MSG:", data.decode("utf-8"))
            id, content, msg = decode_msg(data.decode("utf-8"))

            if(content == "01"):
                """
                #halve server list if it gets too large
                if(len(msg_list) > MAX_MESSAGES):
                    msg_list = msg_list[len(msg_list)/2:]
                #halve our personal list if it gets too large
                if(len(my_msg_id_list) > MAX_MESSAGES):
                    my_msg_id_list = my_msg_id_list[len(my_msg_id_list)/2:]
                """

                msg_id = random_string(8)
                msg_list.append( (msg_id, id, msg) )
                for msg_id_l, id_l, msg_l in msg_list:
                    if(msg_id_l not in my_msg_id_list):
                        my_msg_id_list.append(msg_id_l)
                        payload = f"{msg_id_l}02{id_l} > {msg_l}\n"
                        await websocket.send(payload)

            if(content == "03"):
                 for msg_id_l, id_l, msg_l in msg_list:
                    if(msg_id_l not in my_msg_id_list):
                        my_msg_id_list.append(msg_id_l)
                        payload = f"{msg_id_l}02{id_l} > {msg_l}\n"
                        await websocket.send(payload)

    except Exception:
        print("User left")
        return


def decode_msg(message):
    #always need an id, and a message type, content can be optional
    id = message[0:8]
    type = message[8:10]
    content = None 
    try:
        content = message[10:]
    except Exception:
        pass

    return id, type, content

def random_string(length):
    #generates a random_string of a given length
    return ''.join(random.choice(string.ascii_letters) for x in range(length))

# Create websocket server
start_server = websockets.serve(server, "localhost", 8000)

# Start and run websocket server forever
try:
    loop = asyncio.get_event_loop()
    loop.run_until_complete(start_server)
    loop.run_forever()
except KeyboardInterrupt:
    print("exiting...")
    sys.exit()