import speech_recognition as sr
import pyttsx3
import webbrowser
import time
import sys
engine = pyttsx3.init()
engine.setProperty('rate', 170)  
engine.setProperty('volume', 1.0) 
WAKE_WORD = 'priyanshu'
APP_MAP = {
    'youtube':   'https://www.youtube.com',
    'whatsapp':  'https://web.whatsapp.com',
    'instagram': 'https://www.instagram.com',
    'google':    'https://www.google.com',
    'gmail':     'https://mail.google.com',
    'twitter':   'https://www.twitter.com',
    'spotify':   'https://open.spotify.com/',
}
RESPONSES = {
    'youtube':   'Opening YouTube for you, boss!',
    'whatsapp':  'Launching WhatsApp Web, boss!',
    'instagram': 'Opening Instagram, boss!',
    'google':    'Taking you to Google, boss!',
    'gmail':     'Opening your Gmail, boss!',
    'twitter':   'Opening Twitter for you, boss!',
}
def speak(text: str) -> None:
    print(f"[Priyanshu AI] 🔊 {text}")
    engine.say(text)
    engine.runAndWait()
def listen(recognizer: sr.Recognizer, source: sr.Microphone,
           timeout: int = 5, phrase_limit: int = 6) -> str | None:
    try:
        audio = recognizer.listen(source, timeout=timeout,
                                    phrase_time_limit=phrase_limit)
        text = recognizer.recognize_google(audio)
        return text.lower().strip()
    except sr.WaitTimeoutError:
        return None   # silence — keep looping
    except sr.UnknownValueError:
        return None   # couldn't understand speech
    except sr.RequestError as e:
        print(f"[Error] Google Speech API unreachable: {e}")
        print("       (Check your internet connection)")
        return None
def handle_command(command: str) -> bool:
    """
    Parse the command string and act on it.
    Returns True if the assistant should stop.
    """
    # Stop / quit
    if 'stop' in command or 'exit' in command or 'quit' in command:
        speak("Goodbye, boss! Shutting down Priyanshu AI.")
        return True
    if 'open' in command:
        for app, url in APP_MAP.items():
            if app in command:
                response = RESPONSES.get(app, f"Opening {app.capitalize()}, boss!")
                speak(response)
                webbrowser.open(url)
                return False
        speak("I heard 'open' but I don't know that app yet, boss.")
    else:
        speak("I'm not sure what you want, boss. Try saying open YouTube.")
    return False
def main():
    recognizer = sr.Recognizer()
    recognizer.energy_threshold = 300   # adjust for your mic/room
    recognizer.dynamic_energy_threshold = True
    print("""
╔══════════════════════════════════════╗
║        Priyanshu AI  v1.0            ║
║   Say 'Priyanshu open YouTube'       ║
║   Say 'Priyanshu stop' to quit       ║
╚══════════════════════════════════════╝
""")

    with sr.Microphone() as source:
        print("[Setup] Calibrating for ambient noise… please wait.")
        recognizer.adjust_for_ambient_noise(source, duration=2)
        print("[Ready] Listening for wake word: 'Priyanshu'\n")
        speak("Priyanshu AI is ready. Say my name followed by a command, boss.")

        while True:
            print("[Idle] Waiting for wake word…", end='\r')
            phrase = listen(recognizer, source, timeout=8, phrase_limit=8)

            if phrase is None:
                continue

            print(f"[Heard] {phrase}")

            if WAKE_WORD in phrase:
                print("[Wake] Wake word detected!")
                # Remove wake word to isolate the command
                command = phrase.replace(WAKE_WORD, '').strip()

                if not command:
                    # Wake word said alone — prompt the user
                    speak("Yes boss? What would you like me to open?")
                    command = listen(recognizer, source, timeout=6, phrase_limit=6)
                    if command is None:
                        speak("I didn't catch that. Try again, boss.")
                        continue

                should_stop = handle_command(command)
                if should_stop:
                    break

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n[Quit] Interrupted by user.")
        sys.exit(0)