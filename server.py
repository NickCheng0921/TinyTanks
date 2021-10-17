import asyncio
import websockets

# https://limecoda.com/how-to-build-basic-websocket-server-python/
print("Running Server...")
async def server(websocket, path):
    # Get received data from websocket
    data = await websocket.recv()
    print("RECEIVED MESSAGE: ", data.decode("utf-8"))

    # Send response back to client to acknowledge receiving message
    await websocket.send("SERVER SAYS: Hello Pranav!!!")

# Create websocket server
start_server = websockets.serve(server, "localhost", 8000)

# Start and run websocket server forever
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()