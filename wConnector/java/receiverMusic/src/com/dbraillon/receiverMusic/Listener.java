package com.dbraillon.receiverMusic;

import java.applet.AudioClip;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
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
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.Mixer;
import javax.sound.sampled.spi.MixerProvider;


public class Listener implements Runnable {

	private IReceiver _iReceiver;
	private ByteArrayInputStream _input;
	private boolean test;
	private Thread t;
	
	public Listener(IReceiver iReceiver) {
		
		_iReceiver = iReceiver;
		test = true;
		
		t = new Thread(new Runnable() {
			
			@Override
			public void run() {
				
				while(true) {
					
					byte[] bytes = _iReceiver.get();
					
					if(_input != null) {
						
						ByteArrayOutputStream o = new ByteArrayOutputStream();
						try {
							byte[] bb = new byte[_input.available()];
							_input.read(bb);
							o.write(bb);
							o.write(bytes);
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						_input = new ByteArrayInputStream(o.toByteArray());
					}
					_input = new ByteArrayInputStream(_iReceiver.get());
					try {
						Thread.sleep(100);
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
				
			}
		});
	}
	
	public static void copyStream(ByteArrayInputStream input, ByteArrayOutputStream output)
		    throws IOException
		{
		    byte[] buffer = new byte[512]; // Adjust if you want
		    int bytesRead;
		    while ((bytesRead = input.read(buffer)) != -1)
		    {
		        output.write(buffer, 0, bytesRead);
		        
		        
		    }
		}
	
	@Override
	public void run() {
		
		while(true) {
			
				
			
				if(test) {
				
					byte[] bytes = _iReceiver.get();
					
					if(bytes.length > 0) {
						
						ByteArrayInputStream ss = new ByteArrayInputStream(bytes);
						ss.
						AudioInputStream s;
						s = AudioSystem.getAudioInputStream(f, in)
						AudioFormat.Encoding e = new AudioFormat.Encoding("PCM_SIGNED");
						AudioFormat f = new AudioFormat(e, (float) 44100.0, 16, 2, 4, (float) 44100.0, false);
						test = false;
						//System.out.println("LECTURE");
						Clip clip = null;
						
						try {
							clip = AudioSystem.getClip();
						} catch (LineUnavailableException e2) {
							System.out.println("Erreur get Clip : " + e2.getMessage());
						}
						clip.addLineListener(new LineListener() {
							
							@Override
							public void update(LineEvent event) {
								
								if (event.getType() == Type.STOP) {
									
									test = true;
								}
							}
						});
						try {
							clip.open(f, bytes, 0, bytes.length);
						} catch (LineUnavailableException e1) {
							System.out.println("Erreur open : " + e1.getMessage());
						}
						clip.start();
					}
				}
			
		}
	}
}
