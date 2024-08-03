import asyncio
from frameutils import Bluetooth


async def main():
    b = Bluetooth()

    await b.connect(print_response_handler=lambda x: print(x))

    # await b.send_lua("frame.display.text('Hello, World!', 1, 1)")
    # await b.send_lua("frame.display.show()")

    await b.upload_file('./main.lua', 'main.lua')
    await b.send_lua("require('main')")

    await asyncio.sleep(1)

    await b.disconnect()
    print("Disconnected from Frame device.")

if __name__ == "__main__":
    asyncio.run(main())