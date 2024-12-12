#!/bin/bash

# Визначаємо директорію для проекту
PROJECT_DIR="cli_monitor"
VENV_DIR="$PROJECT_DIR/.venv"

# Перевіряємо, чи існує папка проекту, і створюємо її
mkdir $PROJECT_DIR

cd $PROJECT_DIR

# Створюємо віртуальне середовище, якщо воно не існує
mkdir .venv
python3 -m venv .venv


# Активуємо віртуальне середовище
source .venv/bin/activate

# Встановлюємо необхідні бібліотеки
echo "Встановлюємо бібліотеки..."
pip install urwid
pip install psutil
pip install windows-curses

# Створюємо файл main.py з кодом
echo "Створюємо main.py..."

cat <<EOL > main.py
import urwid
import psutil
import time

class SystemMonitor:
    def __init__(self):
        self.palette = [
            ('header', 'light green', 'black'),
            ('body', 'light cyan', 'black'),
            ('key', 'light green', 'black'),
        ]

        self.cpu_usage_text = urwid.Text(u"CPU Usage: -- %")
        self.memory_usage_text = urwid.Text(u"Memory Usage: -- %")

        self.header = urwid.Text(u"System Monitor")
        self.body = urwid.Pile([self.header, self.cpu_usage_text, self.memory_usage_text])

        self.top_widget = urwid.Filler(self.body)

    def update_data(self):
        # Отримуємо дані про CPU та пам'ять
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()

        # Оновлюємо текст на екрані
        self.cpu_usage_text.set_text(f"CPU Usage: {cpu_percent}%")
        self.memory_usage_text.set_text(f"Memory Usage: {memory.percent}%")

    def run(self):
        loop = urwid.MainLoop(self.top_widget, palette=self.palette, unhandled_input=self.exit_on_q)
        loop.set_alarm_in(1, self.update_screen)
        loop.run()

    def update_screen(self, loop, user_data):
        self.update_data()  # Оновлюємо дані
        loop.draw_screen()  # Перемальовуємо екран
        loop.set_alarm_in(1, self.update_screen)  # Оновлюємо кожну секунду

    def exit_on_q(self, key):
        if key in ('q', 'Q'):
            raise urwid.ExitMainLoop()

if __name__ == '__main__':
    monitor = SystemMonitor()
    monitor.run()
EOL

cat <<EOL> start.sh
source .venv/bin/activate
python main.py
EOL

chmod +x start.sh

# Запускаємо код
echo "Запускаємо програму..."
chmod +x main.py
python main.py