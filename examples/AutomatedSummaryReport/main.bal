import ballerina/io;
import ballerinax/slack;

// Define the Slack API token
configurable string token = ?;

// Define a record type to hold channel information
type ChannelType record {
    string id;
};

// Define a record type to hold the response structure of the channels list
type Channels record {|
    boolean ok;
    ChannelType[] channels;
|};

// Define a record type to hold text messages
type TextType record {
    string text;
};

// Define a record type to hold the response structure of the conversation history
type History record {
    boolean ok;
    TextType[] texts;
};

// Initialize the Slack client with the provided token
final slack:Client slack = check new Client({
    auth: {
        token: value
    }
});

public function main() returns error? {
    // Fetch the list of channels
    json channelResponse = check slack->/conversations\.list();
    Channels channels = check channelResponse.cloneWithType(Channels);

    // Array to store the latest text messages from each channel
    string[] latestText;

    // Iterate through each channel to get the latest message
    foreach ChannelType channel in channels.channels {
        // Fetch the conversation history for the current channel
        json historyResponse = check slack->/conversations\.history({channel: channel.id});
        History history = check historyResponse.cloneWithType(History);

        // Get the latest text message from the conversation history
        TextType[] texts = history.texts;
        latestText.push(texts[0].text);
    }

    // Construct the stand-up report message
    string textMessage = "Automated Stand Up Report: ";
    int i = 1;
    foreach string text in latestText {
        textMessage += string `${i}. ${text}\n`;
        i += 1;
    }

    // Post the stand-up report message to the "general" channel
    json postMessageResult = check slack->/chat\.postMessage.post({channel: "general", text: textMessage});
}
