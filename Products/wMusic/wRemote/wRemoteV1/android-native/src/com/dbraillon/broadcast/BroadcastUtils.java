package com.dbraillon.broadcast;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.Enumeration;

import android.content.Context;
import android.net.DhcpInfo;
import android.net.wifi.WifiManager;

public class BroadcastUtils {

	private static final int TIMEOUT_RECEPTION_RESPONSE = 10000;
	private Context mContext;
	
	public BroadcastUtils(Context c) {
		
		mContext = c;
	}
	
	public InetAddress getBroadcastAddress() throws UnknownHostException {
		
		WifiManager wifiManager = (WifiManager) mContext.getSystemService(Context.WIFI_SERVICE);
		DhcpInfo dhcp = wifiManager.getDhcpInfo();
		
		int broadcast = (dhcp.ipAddress & dhcp.netmask) | ~dhcp.netmask;
		byte[] quads = new byte[4];
		
		for(int k=0; k<4; k++) {
			quads[k] = (byte) ((broadcast >> k * 8) & 0xFF);
		}
		
		return InetAddress.getByAddress(quads);
	}
	
	public DatagramPacket sendUDPBroadcast(String request, int port) throws IOException {
		
		DatagramSocket socket = new DatagramSocket(port);
		socket.setBroadcast(true);
		
		InetAddress broadcastAddress = getBroadcastAddress();
		
		DatagramPacket packet = new DatagramPacket(request.getBytes(), request.length(), broadcastAddress, port);
		
		socket.send(packet);
		
		
		byte[] buffer = new byte[1024];
		packet = new DatagramPacket(buffer, buffer.length);
		socket.setSoTimeout(TIMEOUT_RECEPTION_RESPONSE);
		
		String address = getMyAddress();
		socket.receive(packet);
		while(packet.getAddress().getHostAddress().contains(address))
		{
			socket.receive(packet);
		}
		
		socket.close();
		
		
		return packet;
	}

	private String getMyAddress() throws SocketException {
		
		for(Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) {
			
			NetworkInterface inter = en.nextElement();
			for(Enumeration<InetAddress> addresses = inter.getInetAddresses(); addresses.hasMoreElements();) {
				
				InetAddress inetAddress = addresses.nextElement();
				if(!inetAddress.isLoopbackAddress()) {
					
					return inetAddress.getHostAddress();
				}
			}
		}
		
		return null;
	}
}
