package com.dbraillon.spotifyeverywhere;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.Console;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;

public class Main {

	private DatagramSocket socket;
	private ByteArrayOutputStream outputStream;
	
	private Runnable r = new Runnable() {
		
		@Override
		public void run() {
			
			byte[] b = new byte[8212];
			DatagramPacket packet = new DatagramPacket(b, b.length);
			
			try {
				socket.receive(packet);
				outputStream.write(b, 0, b.length);
				System.out.println(packet.getAddress().toString());
			} catch (IOException e) {
				System.out.println("Erreur reception");
			}
		}
	};
	
	public Main() {
		
		try {
			socket = new DatagramSocket(1337);
		} catch (SocketException e) {
			System.out.println("Erreur socket");
		}
		
		outputStream = new ByteArrayOutputStream();
	}
	
	public void start() {
		
		Thread t = new Thread(r);
		t.start();		
	}
	
	public static void main(String[] args) throws IOException, InterruptedException {
		
		Thread thread = new Thread(new Receiver());
		thread.start();
		
		Boolean isRunning = Boolean.TRUE;
		
		while(isRunning) {
			
			int number = System.in.read();
			if(number == 113) {
				
				System.out.println("Demande de fermuture du programme");
				isRunning = Boolean.FALSE;
			}
		}
		
		System.out.println("Demande de la fermeture sécurisé du thread");
		thread.interrupt();
		
		System.out.println("En attente que le thread meurt...");
		thread.join();
		System.out.println("Le thread est mort");
	}
}
