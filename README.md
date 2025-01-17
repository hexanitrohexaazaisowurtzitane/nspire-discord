# nspire-discord
A program I wrote both in inspired-lua and c for my project to implement discord in the Ti Nspire
It uses an ESP8266 to go online and I have both a USB-B mini cable to connect from the top of the calc or a custom made dock connector adapter (only works with ndless, so I cant really use it) - picture below
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
