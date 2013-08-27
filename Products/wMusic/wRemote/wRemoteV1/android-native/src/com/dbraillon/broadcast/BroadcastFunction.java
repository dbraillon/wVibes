package com.dbraillon.broadcast;

import java.io.IOException;
import java.net.DatagramPacket;

import android.content.Context;
import android.net.wifi.WifiManager;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;

public class BroadcastFunction implements FREFunction {

	public FREObject call(FREContext context, FREObject[] args) {
		
		String request = "";
		int port = 0;
		
		try {
			request = args[0].getAsString();
			port = args[1].getAsInt();
		}
		catch (IllegalStateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		catch (FRETypeMismatchException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		catch (FREInvalidObjectException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		catch (FREWrongThreadException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		String ns = Context.WIFI_SERVICE;
		BroadcastUtils broadcastUtils = new BroadcastUtils(context.getActivity());
		
		DatagramPacket packet = null;
		try {
			packet = broadcastUtils.sendUDPBroadcast(request, port);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		byte[] data = packet.getData();
		
		
		FREObject obj = null;
		try {
			obj = FREObject.newObject(new String(data));
		} catch (FREWrongThreadException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return obj;
	}

}
