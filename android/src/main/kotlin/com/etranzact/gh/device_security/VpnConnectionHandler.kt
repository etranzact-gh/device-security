package package com.etranzact.gh.device_security

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.Handler
import android.os.Looper
import com.pichillilorenzo.flutter_inappwebview_android.Util.log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class VpnConnectionHandler(private val context: Context) {
    private val channel = "vpn_status_channel"

    fun setupChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var networkCallback: ConnectivityManager.NetworkCallback? = null
                private val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                private val mainHandler = Handler(Looper.getMainLooper())

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    val activeVpnNetworks = mutableSetOf<Network>()

                    // Emit initial status via activeNetwork to provide an immediate value to Flutter
                    val activeNetwork = connectivityManager.activeNetwork
                    val caps = connectivityManager.getNetworkCapabilities(activeNetwork)
                    val isInitiallyVpn = caps?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true
                    mainHandler.post { events?.success(isInitiallyVpn) }

                    networkCallback = object : ConnectivityManager.NetworkCallback() {
                        override fun onAvailable(network: Network) {
                            activeVpnNetworks.add(network)
                            mainHandler.post { events?.success(activeVpnNetworks.isNotEmpty()) }
                        }

                        override fun onLost(network: Network) {
                            activeVpnNetworks.remove(network)
                            mainHandler.post { events?.success(activeVpnNetworks.isNotEmpty()) }
                        }
                    }

                    // To listen for VPNs, we MUST remove NET_CAPABILITY_NOT_VPN, 
                    // which is added to NetworkRequests by default.
                    val request = NetworkRequest.Builder()
                        .addTransportType(NetworkCapabilities.TRANSPORT_VPN)
                        .removeCapability(NetworkCapabilities.NET_CAPABILITY_NOT_VPN)
                        .build()

                    connectivityManager.registerNetworkCallback(request, networkCallback!!)
                }

                override fun onCancel(arguments: Any?) {
                    networkCallback?.let {
                        connectivityManager.unregisterNetworkCallback(it)
                    }
                    networkCallback = null
                }
            }
        )
    }
}
