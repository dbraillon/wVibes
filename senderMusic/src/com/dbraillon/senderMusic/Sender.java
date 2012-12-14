package com.dbraillon.senderMusic;

import java.io.File;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioFormat.Encoding;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.UnsupportedAudioFileException;

public class Sender {

	public Sender() throws UnsupportedAudioFileException, IOException, LineUnavailableException, InterruptedException {
		
		MulticastSocket socket = new MulticastSocket();
		InetAddress address = InetAddress.getByName("224.2.2.2");
		
		String path = "C:\\_perso\\_workspaces\\_java\\wmusic\\senderMusic\\assets\\music.wav";
		AudioInputStream audioInputStream = AudioSystem.getAudioInputStream(new File(path));
		
		
		AudioFormat f = audioInputStream.getFormat();
		System.out.println("sample rate : " + f.getSampleRate());
		System.out.println("sample size in bits : " + f.getSampleSizeInBits());
		System.out.println("channels : " + f.getChannels());
		System.out.println("frame size : " + f.getFrameSize());
		System.out.println("frame rate : " + f.getFrameRate());
		System.out.println("big endian : " + f.isBigEndian());
		
		Encoding enc = f.getEncoding();
		System.out.println("encoding : " + enc.toString());
		
		while(true) {
			
			byte[] bytes = new byte[512];  
			audioInputStream.read(bytes);
			//Clip clip = AudioSystem.getClip();
			//clip.open(audioInputStream);
			//clip.start();
			DatagramPacket packet = new DatagramPacket(bytes, bytes.length, address, 1337);
			socket.send(packet);
			
			//Thread.sleep(100000);
		}
	}
	
	public static void main(String[] args) throws UnsupportedAudioFileException, IOException, LineUnavailableException, InterruptedException {
		
		Sender s = new Sender();
	}
}
