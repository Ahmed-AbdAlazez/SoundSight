# 👓 EchoLens

### 🗣️ Smart Glasses for Real-Time Speech Transcription and Dysarthric Speech Recognition

🏆 **3rd Place Winner – 15th Research Day**
🎓 Cairo University Faculty of Engineering

---

# 🌟 Overview

EchoLens is an AI-powered assistive technology project developed for the **15th Research Day at Cairo University Faculty of Engineering**.

The project was designed to help deaf and hard-of-hearing individuals communicate more effectively by providing real-time speech transcription directly within the user's field of view through a smart glasses system.

In addition to real-time speech transcription, EchoLens includes a specialized AI model trained to recognize **dysarthric speech**, enabling better communication support for individuals with speech disorders.

The project combines:

🤖 Artificial Intelligence
📐 Mathematics
🎙️ Speech Processing
⚡ Embedded Systems
📱 Mobile Development
🔍 Optical Engineering

to create a low-cost and accessible assistive solution.

---

# 🏆 Achievement

🥉 **3rd Place – 15th Research Day**

🎓 Faculty of Engineering, Cairo University

The project was presented as a demonstration of how mathematical concepts and artificial intelligence can be applied to solve real-world accessibility challenges.

---

# ❗ Problem Statement

Communication remains a significant challenge for many deaf and hard-of-hearing individuals.

Although speech recognition technologies have improved dramatically, many existing solutions suffer from:

* 💰 High cost
* 🚶 Limited portability
* 🗣️ Limited support for speech disorders
* 🌐 Dependence on cloud services and internet connectivity

Additionally, individuals with dysarthria often experience poor transcription accuracy because most speech recognition systems are trained primarily on typical speech.

EchoLens was developed to address these challenges through an affordable, portable, and completely offline solution.

---

# 🎯 Project Objectives

The primary objectives of EchoLens are:

✅ Provide real-time speech-to-text transcription.

✅ Display text directly inside smart glasses.

✅ Operate fully offline.

✅ Support communication for deaf and hard-of-hearing users.

✅ Improve transcription accuracy for dysarthric speech.

✅ Demonstrate the application of mathematics in speech recognition systems.

✅ Create an affordable assistive technology solution.

---

# ⚙️ System Architecture

EchoLens consists of two integrated subsystems:

## 👓 Part 1: Smart Glasses Platform

### 🎙️ Step 1: Audio Capture

A microphone captures speech from the surrounding environment in real time.

### 📱 Step 2: Mobile Application

A Flutter application receives the audio and performs speech transcription.

The application is responsible for:

* Capturing audio
* Processing speech
* Generating transcriptions
* Managing communication with the smart glasses

### 📡 Step 3: Bluetooth Communication

The Flutter application communicates wirelessly with an ESP-based hardware module using Bluetooth.

Because the system operates completely offline, no internet connection is required.

### 💡 Step 4: OLED Display

The transcribed text is displayed on a compact OLED screen mounted on the glasses.

### 🔍 Step 5: Optical Projection

EchoLens uses an optical reflection system consisting of:

* Two mirrors
* 45° reflection angles

The reflected text appears directly in the user's field of view while maintaining visibility of the surrounding environment.

---

# 🔧 Hardware Components

* ⚡ ESP Microcontroller
* 💡 OLED Display
* 🎙️ Microphone Module
* 📡 Bluetooth Communication
* 🪞 Optical Mirror System
* 🔋 Battery System
* 👓 Custom Glasses Frame

---

# 📸 Project Gallery

## 👓 Smart Glasses Prototype

<p align="center">
Add Smart Glasses Images Here
</p>

---

## 🔧 Hardware Assembly

<p align="center">
Add Hardware Images Here
</p>

---

## 📱 Mobile Application Screenshots

<p align="center">
Add Flutter Application Screenshots Here
</p>

---

## 🎥 System Demonstration

<p align="center">
Add Demonstration Photos or GIFs Here
</p>

---

# 🧠 Part 2: Dysarthric Speech Recognition Model

## 💭 Motivation

While traditional speech recognition systems perform well on normal speech, they often struggle when processing speech produced by individuals with dysarthria.

Dysarthria is a motor speech disorder that affects articulation and speech clarity, making accurate transcription significantly more challenging.

To address this limitation, we developed a dedicated dysarthric speech recognition model.

---

# 📚 Dataset

The model was trained using the **TORGO Dataset**, a benchmark dataset containing recordings from speakers with dysarthria.

The dataset includes:

* 🗣️ Dysarthric speakers
* 👥 Control speakers
* 🎙️ Multiple speech tasks
* 📝 Human-generated transcriptions

---

# 🤖 Model Architecture

### Base Model

* OpenAI Whisper Small

### Frameworks

* PyTorch
* Hugging Face Transformers

### Training Strategy

* Decoder Fine-Tuning
* Frozen Encoder
* English Speech Recognition

---

# 🛠️ Data Preprocessing

Several preprocessing steps were applied before training:

* 🎵 Audio resampling to 16 kHz
* 🔤 Text normalization
* 🔡 Lowercase conversion
* ✨ Punctuation cleaning
* 🎙️ Whisper feature extraction
* 💾 Dataset caching for efficient training

---

# 🚀 Training Configuration

| Parameter             | Value            |
| --------------------- | ---------------- |
| Model                 | Whisper Small    |
| Learning Rate         | 1e-5             |
| Epochs                | 5                |
| Batch Size            | 1                |
| Gradient Accumulation | 4                |
| Sampling Rate         | 16 kHz           |
| Framework             | PyTorch          |
| Training Environment  | Google Colab GPU |

---

# 📈 Results

## 🎯 Dysarthric Speech Recognition Performance

The fine-tuned EchoLens model achieved an approximate:

### ✅ WER: 25–30%

on dysarthric speech samples.

General-purpose speech recognition systems showed noticeably lower performance on dysarthric speech compared to our specialized model.

These results demonstrate the effectiveness of domain-specific fine-tuning for speech disorders.

---

# 📐 Mathematical Foundations

A key objective of this project was demonstrating how mathematics can be used in speech transcription systems.

The project incorporates concepts from:

## 📊 Signal Processing

* Audio Sampling
* Spectrogram Generation
* Frequency Analysis
* Feature Extraction

## 🔢 Linear Algebra

Speech recognition models rely heavily on:

* Matrices
* Vectors
* Linear Transformations
* Matrix Multiplication
* Attention Mechanisms

## 📉 Optimization

Training utilizes mathematical optimization techniques including:

* Gradient Descent
* Backpropagation
* Loss Minimization

## 🧠 Deep Learning

Neural networks learn complex speech representations through mathematical modeling and parameter optimization.

---

# 🔒 Fully Offline System

One of the major advantages of EchoLens is its fully offline architecture.

✅ No internet connection required

✅ Enhanced privacy

✅ Reduced latency

✅ Reliable operation in low-connectivity environments

---

# 💰 Cost Analysis

Many assistive technologies are prohibitively expensive.

EchoLens was designed as a low-cost alternative.

### Estimated Prototype Cost

# 💵 ~600 EGP

This makes EchoLens a promising solution for wider accessibility.

---

# 🛠️ Technologies Used

### 🤖 Artificial Intelligence

* OpenAI Whisper
* Hugging Face Transformers
* PyTorch

### 📱 Mobile Development

* Flutter

### ⚡ Embedded Systems

* ESP Microcontroller
* Bluetooth Communication

### 🎵 Audio Processing

* Librosa

### ☁️ Development Environment

* Google Colab

---

# 🚀 Future Work

* 🌍 Multi-language support
* ⚡ Real-time on-device inference
* 📱 Mobile deployment optimization
* 🥽 AR display integration
* 📊 Larger dysarthric datasets
* 🎯 Improved transcription accuracy
* 🔋 Better power efficiency

---

# 👨‍💻 Team Members

## 👑 Team Leader

* Ahmed Abd Alazez

## 🤝 Team Members

* Abdullah Hussien
* Abdullah Hesham
* Hashem Elhelo
* Ziad Samir
* Ziad Mahfouz
* Ahmed Seddik
* Seif Mahmoud
* Omar Moharam

---

# 🎓 Supervisor

**Dr. Samah Elshafie**

---

# 🙏 Acknowledgements

This project was developed and presented at the **15th Research Day, Faculty of Engineering, Cairo University**.

We would like to thank our supervisor, mentors, and the Faculty of Engineering for their support and guidance throughout the development of EchoLens.

---

# ❤️ Because Every Voice Matters.
