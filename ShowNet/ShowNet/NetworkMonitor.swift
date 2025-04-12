import Foundation
import Darwin

class NetworkMonitor {
    private var previousInBytes: UInt64 = 0
    private var previousOutBytes: UInt64 = 0
    private var lastCheckTime: Date = Date()
    
    func getCurrentSpeeds() -> (Double, Double) {
        let (inBytes, outBytes) = getNetworkBytes()
        let now = Date()
        
        let timeInterval = now.timeIntervalSince(lastCheckTime)
        
        // Calculate bytes per second
        let inBytesPerSecond = timeInterval > 0 ? Double(inBytes - previousInBytes) / timeInterval : 0
        let outBytesPerSecond = timeInterval > 0 ? Double(outBytes - previousOutBytes) / timeInterval : 0
        
        // Update previous values
        previousInBytes = inBytes
        previousOutBytes = outBytes
        lastCheckTime = now
        
        return (outBytesPerSecond, inBytesPerSecond)
    }
    
    private func getNetworkBytes() -> (UInt64, UInt64) {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        var inBytes: UInt64 = 0
        var outBytes: UInt64 = 0
        
        guard getifaddrs(&ifaddr) == 0 else {
            print("Error: getifaddrs failed")
            return (0, 0)
        }
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            guard let interface = ptr?.pointee else {
                continue
            }
            
            let name = String(cString: interface.ifa_name)
            print("Checking interface: \(name)")
            
            // Check if it's a valid interface we want to monitor
            if name.contains("en") || name.contains("pdp_ip") || name.contains("utun") || name.contains("llw") {
                if interface.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
                    if let networkData = interface.ifa_data?.assumingMemoryBound(to: if_data.self).pointee {
                        inBytes += UInt64(networkData.ifi_ibytes)
                        outBytes += UInt64(networkData.ifi_obytes)
                        print("Interface \(name) - In: \(networkData.ifi_ibytes), Out: \(networkData.ifi_obytes)")
                    } else {
                        print("Error: Could not access network data for interface \(name)")
                    }
                } else {
                    print("Interface \(name) is not a link layer interface")
                }
            } else {
                print("Interface \(name) is not a monitored interface")
            }
        }
        
        freeifaddrs(ifaddr)
        print("Total - In: \(inBytes), Out: \(outBytes)")
        return (inBytes, outBytes)
    }
} 