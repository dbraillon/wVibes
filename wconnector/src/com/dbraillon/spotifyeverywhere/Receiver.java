package com.dbraillon.spotifyeverywhere;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;

public class Receiver implements Runnable {

	private DatagramSocket _socket;
	private Boolean _isRunning;
	
	public Receiver() throws SocketException {
		
		_socket = new DatagramSocket(1337);
	}
	
	@Override
	public void run() {
		
		_isRunning = Boolean.TRUE;
		while(_isRunning) {
			
			try {
				
				System.out.println("loop");
				waitDatagramPacket();
				Thread.sleep(500);
			}
			catch (InterruptedException e) {
				
				_isRunning = Boolean.FALSE;
			}
		}
	}

	public void waitDatagramPacket() {
		
		if(listenStartPacket()) {
			
			listenDataPacket();
			listenEndPacket();
		}
	}
	
	public boolean listenStartPacket() {
		
		byte[] bytes = new byte[8];
		DatagramPacket packet = new DatagramPacket(bytes, bytes.length);
		
		
		
		return true;
	}
	
	public void listenDataPacket() {
		
	}
	
	public void listenEndPacket() {
		
	}
}
