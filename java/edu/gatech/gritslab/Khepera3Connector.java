package edu.gatech.gritslab;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.StringTokenizer;


public class Khepera3Connector {
	
	private DatagramSocket mClientSocket;
	private String mHostname;
	private InetAddress mIPAddress;
	private int mPort;
	
	private final int SO_TIMEOUT = 500;
	
	public Khepera3Connector(String hostname, int port) {
		try {
			mClientSocket = new DatagramSocket();
			mClientSocket.setSoTimeout(SO_TIMEOUT);
		} catch (SocketException e) {
			System.err.println("Error: Unable to create socket.");
			System.exit(-1);
		}
		
		
		mHostname = hostname;
		try {
			mIPAddress = InetAddress.getByName(mHostname);
		} catch (UnknownHostException e) {
			System.err.println("Error: Unknown host.");
			System.exit(-1);
		}
		mPort = port;
	}
	
	public void mClose() {
		mClientSocket.close();
	}
	
	public void mSendControl(int vel_r, int vel_l) {
		// $K3DRV,CTRL,REQ,R,L
		String mMessage = "$K3DRV,REQ,CTRL," + vel_r + "," + vel_l;
		byte[] mSendData = new byte[2048];
		byte[] mRecvData = new byte[2048];
		
		mSendData = mMessage.getBytes();
		DatagramPacket mSendPacket = new DatagramPacket(mSendData, mSendData.length, mIPAddress, mPort);
		DatagramPacket mRecvPacket = new DatagramPacket(mRecvData, mRecvData.length);
		
		try {
			mClientSocket.send(mSendPacket);
		} catch (IOException e) {
			System.err.println("Error: Failed to send packet.");
			return;
		} 
		try {
			mClientSocket.receive(mRecvPacket);
		} catch (IOException e) {
			System.err.println("Error: Failed to receive reply.");
			return;
		}
		
//		String mRecvMessage = new String(mRecvPacket.getData());
//		System.out.println("Info: Received message reads '" + mRecvMessage + "'.");
	}
	
	public boolean mSendInit() {
		String mMessage = "$K3DRV,REQ,INIT";
		byte[] mSendData = new byte[2048];
		byte[] mRecvData = new byte[2048];
		
		mSendData = mMessage.getBytes();
		DatagramPacket mSendPacket = new DatagramPacket(mSendData, mSendData.length, mIPAddress, mPort);
		DatagramPacket mRecvPacket = new DatagramPacket(mRecvData, mRecvData.length);
		
		try {
			mClientSocket.send(mSendPacket);
		} catch (IOException e) {
			System.err.println("Error: Failed to send packet.");
			return false;
		} 
		try {
			mClientSocket.receive(mRecvPacket);
			return true;
		} catch (IOException e) {
			System.err.println("Error: Failed to receive reply.");
			return false;
		}
	}
	
	public int[] mRecvData() {
		int[] mData = new int[14]; // FIXME: What about the wheel encoders???
		
		String mMessage = "$K3DRV,REQ,DATA";
		byte[] mSendData = new byte[2048];
		byte[] mRecvData = new byte[2048];
		
		mSendData = mMessage.getBytes();
		DatagramPacket mSendPacket = new DatagramPacket(mSendData, mSendData.length, mIPAddress, mPort);
		DatagramPacket mRecvPacket = new DatagramPacket(mRecvData, mRecvData.length);
		
		try {
			mClientSocket.send(mSendPacket);
		} catch (IOException e) {
			System.err.println("Error: Failed to send packet.");
			return null;
		}
		try {
			mClientSocket.receive(mRecvPacket);
		} catch (IOException e) {
			System.err.println("Error: Failed to receive reply.");
			return null;
		}
		
//		String mRecvMessage = new String(mRecvPacket.getData());
//		System.out.println("Info: Received message reads '" + mRecvPacket.getData() + "'.");
		
		// parse
		
		ArrayList<Integer> data = new ArrayList<Integer>(14);
		
		try {
			String message = new String(mRecvPacket.getData(), "US-ASCII");
//			System.out.println("Info: Received message reads '" + message + "'.");

			StringTokenizer st = new StringTokenizer(message, ",");
//			System.err.println("Number of tokens " + st.countTokens());
			if(!st.nextToken().trim().equals("$K3DRV"))
				return null; // $K3DRV
			if(!st.nextToken().trim().equals("RES"))
				return null; // RES
			if(!st.nextToken().trim().equals("DATA"))
				return null; // DATA
			if(!st.nextToken().trim().equals("IR"))
				return null; // IR
			st.nextToken().trim(); // 11
			
			
			for(int j=0; j<11; j++) {
				data.add(new Integer(st.nextToken().trim()));
			}
			
			if(!st.nextToken().trim().equals("ENC"))
				return null; // ENC
			st.nextToken().trim(); // 2
			
			for(int j=0; j<2; j++) {
				data.add(new Integer(st.nextToken().trim()));
			}
			
		} catch (UnsupportedEncodingException e) {
			System.err.println("Error: Message was incorrectly encoded.");
			return null;
		}
		
		for(int j=0; j<data.size(); j++) {
			mData[j] = data.get(j).intValue();
		}
		
		return mData;
	}
};
