# nspire-discord
A program I wrote both in inspired-lua and c for my project to implement discord in the Ti Nspire
It uses an ESP8266 to go online and I have both a USB-B mini cable to connect from the top of the calc or a custom made dock connector adapter (only works with ndless, so I cant really use it) - picture below

<sub>
Wait! Before you hate...
This is my 1st time developing a project that includes serial, esp ( c lang ), lua and a nspire
As of now, the code is horrible on both sides. I plan to rewrite the code and clean it up when possible!
</sub>

## Welcome pannel && Main chat interface
![image](https://github.com/user-attachments/assets/463c09a8-45ed-4f63-b4f6-a1090e505476)
![image](https://github.com/user-attachments/assets/5d0dd483-9f63-44d6-9939-474fe3f96068)
<!--![image](https://github.com/user-attachments/assets/08c4077e-e058-4a96-b7fc-2f07e79d9d29)
![image](https://github.com/user-attachments/assets/74867b52-a147-450d-a36b-0a3ac36f82ca)-->
 ## How to connect:
 - Make sure that the friends list in discord.tns is updated
 - Make sure that the user token in the ino project is correct
 - Start the program in the calculator
 - Connect ESP to port and wait for a successfull wifi connection (light stops blinking)
   - If you need to update the wifi credentials, you can do so in the loading menu (press enter while light is still blinking)
   - however you must then reconnect the esp to the calculator and restart the program [ESC]
 - If the connection is successful, press enter to begin listening to serial data
 - Serial data is streamed like so: `"<m:CHANNEL_ID>MESSAGE1_CONTENT||MESSAGE2_CONTENT||MESSAGE3_CONTENT</m>`
 - Note: sometimes the chat may take too long to load, it is best to unplug the esp as the cable or connection might have been disconnected
### Friends menu:
<table>
<tr>
<td width="50%">
<img src="https://github.com/user-attachments/assets/b97cb06a-4889-4eff-8a65-883a849f9c02" alt="Friends menu image">
</td>
<td width="50%">
Reads from friends list in tns file and will send update strings to update esp discord channel
Friends list must be like the following:

```lua
friends = {
    -- use channel ids
    "ChatGPT:chatgpt",   -- chatgpt id (TODO)
    "FriendName1:channelId_1",
    "FriendName2:channelId_2",
    "FriendName3:channelId_3",
    "FriendName4:channelId_4",
    --(...)
}
```
</table>

## TODO
- Rewrite calculator serial code ( it works like ahh )
- Clean up the whole code
- Test dock connector serial ( with another calc)
- ### if this project moves forward:
  - add auto friends list updater
  - support for chatGPT or others
  - support for camera ( connected to esp )

<sub>
If you found this somewhat interesting, consider leaving a star so i am kept 'motivated' ^.^
</sub>

## Real life images (usb-b port and dock connector)
![image](https://github.com/user-attachments/assets/2c1b6f1c-8177-4b5a-829a-4c8db26e1e04)
![image](https://github.com/user-attachments/assets/1575c28c-e012-400d-a56b-5194a44e650a)
![image](https://github.com/user-attachments/assets/0ade3b68-ba67-4274-b8ce-9a61cb99a590)

The dock connector requires system version <= 3.1 or ndless to work.
Unfortunately my calculator is set to v6 so I can't to much about this.
For those interested, I used a lad cradle's connector with a 3d printed casing (send me a dm if you want the files)

## Serial data codes:
Chat message: `"<m:CHANNEL_ID>MESSAGE1_CONTENT||MESSAGE2_CONTENT||MESSAGE3_CONTENT</m>\n`

Internet update: `"//UPDATE//ssid||password\n"`

Channel update:  `"//CHANNEL//channel_id\n"`
