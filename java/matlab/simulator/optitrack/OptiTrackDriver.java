package matlab.simulator.optitrack;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.StringTokenizer;


public class OptiTrackDriver {
	
	private DatagramSocket mClientSocket;
	private String mHostname;
	private InetAddress mIPAddress;
	private int mPort;
	
	private final int SO_TIMEOUT = 500;
	
	public OptiTrackDriver(String hostname, int port) {
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
	
	public double[] mRecvData(int id) {
		double[] mData = new double[3]; // FIXME: What about the wheel encoders???
		
		String mMessage = "$OTDRV,REQ,DATA," + id;
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
			System.err.println("Error: Failed to receive reply from optitrack.");
			return null;
		}
		
//		String mRecvMessage = new String(mRecvPacket.getData());
//		System.out.println("Info: Received message reads '" + mRecvPacket.getData() + "'.");
		
		// parse
		
		ArrayList<Double> data = new ArrayList<Double>(3);
		
		try {
			String message = new String(mRecvPacket.getData(), "US-ASCII");
//			System.out.println("Info: Received message reads '" + message + "'.");

			StringTokenizer st = new StringTokenizer(message, ",");
//			System.err.println("Number of tokens " + st.countTokens());
			if(!st.nextToken().trim().equals("$OTDRV"))
				return null; // $K3DRV
			if(!st.nextToken().trim().equals("RES"))
				return null; // RES
			if(!st.nextToken().trim().equals("DATA"))
				return null; // DATA
			if(!(new Integer(st.nextToken().trim()) == id))
				return null; // IR
			
			
			for(int j=0; j<3; j++) {
				data.add(new Double(st.nextToken().trim()));
			}
			
		} catch (UnsupportedEncodingException e) {
			System.err.println("Error: Message was incorrectly encoded.");
			return null;
		}
		
		for(int j=0; j<data.size(); j++) {
			mData[j] = data.get(j).doubleValue();
		}
		
		return mData;
	}
};
