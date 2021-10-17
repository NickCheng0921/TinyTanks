import asyncio
import websockets
import time
import sys

# https://limecoda.com/how-to-build-basic-websocket-server-python/
server_id = "XSERVERX"

async def server(websocket, path):
    print("Running Server...")
    # Get received data from websocket
    data = await websocket.recv()
    id, content, msg = decode_msg(data.decode("utf-8"))
    print(f"ID {id} CONTENT {content} MSG {msg}")

    if(content == "01"):
        payload = server_id + "02" + msg
        await websocket.send(payload)

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