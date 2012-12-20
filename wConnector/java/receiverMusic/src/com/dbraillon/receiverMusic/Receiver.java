package com.dbraillon.receiverMusic;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.InetAddress;
import java.net.MulticastSocket;

import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.UnsupportedAudioFileException;

public class Receiver implements Runnable, IReceiver {

	private ByteArrayOutputStream _outputStream;
	
	public Receiver() {
		_outputStream = new ByteArrayOutputStream();
	}
	
	@Override
	public void run() {
		
		try {
		
			MulticastSocket socket = new MulticastSocket(1337);
			InetAddress address = InetAddress.getByName("224.2.2.2");
			socket.joinGroup(address);
			
			_outputStream = new ByteArrayOutputStream();
			
			while(true) {
				
				byte[] bytes = new byte[512];
				DatagramPacket packet = new DatagramPacket(bytes, bytes.length);
				
				socket.receive(packet);
				_outputStream.write(packet.getData());
				//System.out.println("Taille du stream reçu : " + _outputStream.size());
				
				//Thread.sleep(1);
			}
		
		}
		catch(Exception e) {
			
			System.out.println("ERREUR");
		}
	}
	
	@Override
	public byte[] get() {
	
		byte[] bytes = _outputStream.toByteArray();
		
		//System.out.println(_outputStream.size());
		_outputStream.reset();
		
		return bytes;
	}
	
	public static void main(String[] args) throws IOException, UnsupportedAudioFileException, LineUnavailableException, InterruptedException {
		
		Receiver receiver = new Receiver();
		Listener listener = new Listener(receiver);
		
		Thread receive = new Thread(receiver);
		Thread listen = new Thread(listener);
		
		receive.start();
		listen.start();
		
		while(true);
	}

	
}
