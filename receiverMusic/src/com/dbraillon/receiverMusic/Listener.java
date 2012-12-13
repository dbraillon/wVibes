package com.dbraillon.receiverMusic;

import java.io.ByteArrayOutputStream;
import java.net.URL;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.LineEvent;
import javax.sound.sampled.LineEvent.Type;
import javax.sound.sampled.LineListener;


public class Listener implements Runnable {

	private IReceiver _iReceiver;
	private final BlockingQueue<URL> queue = new ArrayBlockingQueue<URL>(1);
	private boolean test;
	
	
	public Listener(IReceiver iReceiver) {
		
		_iReceiver = iReceiver;
		test = true;
	}
	
	
	@Override
	public void run() {
		
		while(true) {
			
			try {
			
				if(test) {
				
					ByteArrayOutputStream output = _iReceiver.get();
					byte[] bytes = output.toByteArray();
					output.reset();
					
					if(bytes.length > 0) {
						
						AudioFormat.Encoding e = new AudioFormat.Encoding("PCM_SIGNED");
						AudioFormat f = new AudioFormat(e, (float) 44100.0, 16, 2, 4, (float) 44100.0, false);
						test = false;
						Clip clip = AudioSystem.getClip();
						clip.addLineListener(new LineListener() {
							
							@Override
							public void update(LineEvent event) {
								
								
								if (event.getType() != Type.STOP) {
									return;
								}
	
								
								System.out.println("EVENT !");
								test = true;
								/*
								try {
									queue.take();
								} catch (InterruptedException e) {
									
								}*/
							}
						});
						clip.open(f, bytes, 0, bytes.length);
						clip.start();
					}
				}
			}
			catch(Exception e) {
				
				System.out.println("ERREUR");
			}
		}
	}
}
