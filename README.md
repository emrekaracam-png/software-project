The "Smart-Task" Academic Project Manager -- 25WSB301 CW2 
![Python](https://img.shields.io/badge/python-3.9+-blue.svg)
![CustomTkinter](https://img.shields.io/badge/UI-CustomTkinter-brightgreen)
![SQLite](https://img.shields.io/badge/Database-SQLite-lightgrey)

# Smart-Task Academic Manager
A modern, native desktop application for students to track, prioritize, and manage academic deadlines.

## Overview
**Context & Purpose:** University students frequently struggle to balance competing deadlines across multiple modules, they might even occasionally miss a test or a submission. Standard to-do lists fail to capture the nuances of academic triage     (e.g., sorting by priority vs. sorting by closest deadline). **Smart-Task** solves this academic pain point by providing a high-visibility dashboard with a live countdown engine and strict structural sorting, ensuring students never miss an impending deadline.

![Dashboard screenshot] (https://docs.google.com/document/d/14pQuYu88U2j58z4OUVgbt0B1qjrsMPRwMXOd8BsCoBk/edit?usp=sharing)  *(Note to assessor: Please run the app to view the live GUI)*

## Features
* **Live Deadline Tracking:** Real-time countdown engine calculates days, hours, and minutes until the closest impending deadline.
* **Smart Sorting & Filtering:** Dynamically filter tasks by completion status or priority, and sort logically using SQL `CASE` weighting.
* **Persistent Storage:** Local SQLite database ensures data is safely stored across sessions without the need for an internet connection.
* **Automated Data Formatting:** Auto-capitalization of inputs and localized date masking (displaying `DD-MM-YYYY` while storing machine-readable `YYYY-MM-DD`).

## Getting Started

### Prerequisites
This project requires Python 3.9 or newer. It utilizes the `customtkinter` library for its modern user interface.

### Installation
1. Clone this repository to your local machine:
  
   
