from datetime import *
import asyncio
import websockets
import sys

# https://limecoda.com/how-to-build-basic-websocket-server-python/
print("Running Server...")
server_id = "XSERVERX"
msg_list = []

async def server(websocket, path):
    print("User joined")
    # Get received data from websocket
    try:
        while(True):
            data = await websocket.recv()
            id, content, msg = decode_msg(data.decode("utf-8"))
            msg_list.append( (id, msg) )

            if(content == "01"):

                for id_l, msg_l in msg_list:
                    #time = datetime.strptime(datetime.now().strftime("%d/%m/%y %H:%M"), "%d/%m/%y %H:%M")
                    payload = f"{server_id}02{id_l} > {msg_l}\n"
                    await websocket.send(payload)
    except Exception:
        print("User left")
        return


def decode_msg(message):
    if(len(message) < 11):
        return 

    id = message[0:8]
    type = message[8:10]
    content = message[10:]

    return id, type, content

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