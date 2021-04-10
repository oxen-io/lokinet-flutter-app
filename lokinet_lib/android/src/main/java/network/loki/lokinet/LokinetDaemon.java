package network.loki.lokinet;

import android.content.Intent;
import android.net.VpnService;
import android.os.Binder;
import android.os.IBinder;
import android.os.ParcelFileDescriptor;
import android.util.Log;

import java.nio.ByteBuffer;

public class LokinetDaemon extends VpnService {

    public static final String ACTION_CONNECT = "network.loki.lokinet.START";
    public static final String ACTION_DISCONNECT = "network.loki.lokinet.STOP";
    public static final String LOG_TAG = "LokinetDaemon";
    public static final String MESSAGE_CHANNEL = "LOKINET_DAEMON";

    static {
        System.loadLibrary("lokinet-android");
    }

    private static native ByteBuffer Obtain();

    private static native void Free(ByteBuffer buf);

    public native boolean Configure(LokinetConfig config);

    public native int Mainloop();

    public native boolean IsRunning();

    public native boolean Stop();

    public native void InjectVPNFD();

    public native int GetUDPSocket();

    private static native String DetectFreeRange();

    ByteBuffer impl = null;
    ParcelFileDescriptor iface;
    int m_FD = -1;
    int m_UDPSocket = -1;

    @Override
    public void onCreate() {
        super.onCreate();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        disconnect();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startID) {
        Log.d(LOG_TAG, "onStartCommand()");

        if (intent.getAction().equals(ACTION_DISCONNECT)) {
            disconnect();
            return START_NOT_STICKY;
        } else {
            boolean connectedSucessfully = connect("exit.loki");
            if (connectedSucessfully)
                return START_STICKY;
            else
                return START_NOT_STICKY;
        }
    }

    private boolean connect(String exitNode) {
        if (!IsRunning()) {
            if (impl != null) {
                Free(impl);
                impl = null;
            }
            impl = Obtain();
            if (impl == null) {
                Log.e(LOG_TAG, "got nullptr when creating llarp::Context in jni");
                return false;
            }

            String dataDir = getFilesDir().toString();
            LokinetConfig config;
            try {
                config = new LokinetConfig(dataDir);
            } catch (RuntimeException ex) {
                Log.e(LOG_TAG, ex.toString());
                return false;
            }

            // FIXME: make these configurable
//            String exitNode = "exit.loki";
            String upstreamDNS = "1.1.1.1";
            String ourRange = DetectFreeRange();

            if (ourRange.isEmpty()) {
                Log.e(LOG_TAG, "cannot detect free range");
                return false;
            }

            // set up config values
            config.AddDefaultValue("network", "exit-node", exitNode);
            config.AddDefaultValue("network", "ifaddr", ourRange);
            config.AddDefaultValue("dns", "upstream", upstreamDNS);


            if (!config.Load()) {
                Log.e(LOG_TAG, "failed to load (or create) config file at: " + dataDir + "/loki.network.loki.lokinet.ini");
                return false;
            }

            VpnService.Builder builder = new VpnService.Builder();

            builder.setMtu(1500);

            String[] parts = ourRange.split("/");
            String ourIP = parts[0];
            int ourMask = Integer.parseInt(parts[1]);

            builder.addAddress(ourIP, ourMask);
            builder.addRoute("0.0.0.0", 0);
            builder.addDnsServer(upstreamDNS);
            builder.setSession("Lokinet");
            builder.setConfigureIntent(null);

            iface = builder.establish();
            if (iface == null) {
                Log.e(LOG_TAG, "VPN Interface from builder.establish() came back null");
                return false;
            }

            m_FD = iface.detachFd();

            InjectVPNFD();
            new Thread(() -> {
                Configure(config);
                m_UDPSocket = GetUDPSocket();
                protect(m_UDPSocket);
                Mainloop();
            }).start();

            Log.d(LOG_TAG, "started successfully!");
        } else {
            Log.d(LOG_TAG, "already running");
        }
        return true;
    }

    private void disconnect() {
        if (IsRunning()) {
            Stop();
        }
//        if (impl != null) {
//            Free(impl);
//            impl = null;
//        }
    }

    /**
     * Class for clients to access.  Because we know this service always
     * runs in the same process as its clients, we don't need to deal with
     * IPC.
     */
    public class LocalBinder extends Binder {
        public LokinetDaemon getService() {
            return LokinetDaemon.this;
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return mBinder;
    }

    private final IBinder mBinder = new LocalBinder();
}
