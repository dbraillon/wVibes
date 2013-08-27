package com.dbraillon.broadcast;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class BroadcastExtension implements FREExtension {

	public FREContext createContext(String arg0) {
		return new BroadcastContext();
	}

	public void dispose() {
		// TODO Auto-generated method stub
		
	}

	public void initialize() {
		// TODO Auto-generated method stub
		
	}

}
