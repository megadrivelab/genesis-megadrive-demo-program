# Mega Drive Test Program / Тестовая программа для Sega Mega Drive

[English](#english) | [Русский](#русский)

---

## English

A test program for the **Sega Genesis / Mega Drive**, written in 68000 assembly using **[Easy68k v5.16.01](http://www.easy68k.com/)**.  
Created as part of the [Mega Drive Lab](https://youtube.com/@MegaDriveLabEN) YouTube tutorial series.

### What it does
- Displays a single smiley face tile repeated across the entire screen (all tile map positions)
- Cycles the tile's color continuously

### Previous versions
Each release corresponds to a working version from the tutorial videos.  
Click **[Releases](../../releases)** to download and browse older versions.

### Files
| File | Description |
| :--- | :--- |
| `main.x68` | Main program |
| `inc/equates.inc` | Constants and VDP register definitions |
| `inc/macros.asm` | Macro definitions |
| `rom/rom.bin` | Compiled ROM for emulator |

---

## Русский

Тестовая программа для **Sega Mega Drive**, написанная на ассемблере 68000 в среде **[Easy68k v5.16.01](http://www.easy68k.com/)**.  
Сделана для видео по программированию Sega Mega Drive на моём YouTube-канале [Mega Drive Lab](https://youtube.com/@MegaDriveLab).

### Что делает
- Отображает один тайл-смайлик на всех позициях тайловых карт
- Циклически меняет цвет тайла

### Предыдущие версии
Каждый релиз соответствует работающей версии программы из видео.  
Нажмите **[Releases](../../releases)**, чтобы скачать и посмотреть предыдущие версии.

### Файлы
| Файл | Описание |
| :--- | :--- |
| `main.x68` | Основная программа |
| `inc/equates.inc` | Константы и регистры VDP |
| `inc/macros.asm` | Определения макросов |
| `rom/rom.bin` | Скомпилированный ROM для эмулятора |
