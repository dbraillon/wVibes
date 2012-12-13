package com.dbraillon.spotifyeverywhere;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InterruptedIOException;
import java.io.OutputStream;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.MulticastSocket;
import java.net.SocketException;

public class Receiver implements Runnable {

	private MulticastSocket _socket;
	private InetAddress _address;
	private Boolean _isRunning;
	
	public ByteArrayOutputStream _outputStream;
	
	
	public Receiver() throws IOException {
		
		_socket = new MulticastSocket(1337);
		_address = InetAddress.getByName("224.2.2.2");
		_outputStream = new ByteArrayOutputStream();
	}
	
	@Override
	public void run() {
		
		try {
			_socket.joinGroup(_address);
			_isRunning = Boolean.TRUE;
		} catch (IOException e1) {
			_isRunning = Boolean.FALSE;
		}
		
		while(_isRunning) {
			
			receive();
		}
	}

	public void receive() {
		
		byte[] bytes = new byte[8192];
		DatagramPacket packet = new DatagramPacket(bytes, bytes.length);
		
		try {
			_socket.receive(packet);
			_outputStream.write(bytes, 0, bytes.length);
			
			Thread thread = new Thread(new Runnable() {
				
				@Override
				public void run() {
					
					File file = new File("C:\\text.txt");
					
					try {
						FileOutputStream outputStream = new FileOutputStream(file, true);
						
						String s = _outputStream.toString();
						StringBuilder b = new StringBuilder(s);
						b.insert(s.indexOf("START"), "\n");
						b.insert(s.indexOf("STOP"), "\n");
						
						outputStream.write(b.toString().getBytes());
						outputStream.flush();
						outputStream.close();
						_outputStream.reset();
					} catch (FileNotFoundException e) {
						System.out.println("ERREUR !!");
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
			});
			thread.start();
			
			System.out.println("Address sender : " + packet.getAddress().toString());
		}
		catch(InterruptedIOException e) {
			_isRunning = Boolean.FALSE;
		}
		catch (IOException e) {
			System.out.println("Erreur reception");
		}
	}
	
	public static void main(String[] args) throws IOException, InterruptedException {
		
		Receiver receiver = new Receiver();
		
		Thread thread = new Thread(receiver);
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
