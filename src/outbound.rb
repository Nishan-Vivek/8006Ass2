#User Configuration Section
EXTERNAL_IP="192.168.1.34"
BLOCKED_TCP_PORTS=[23,88,45]
BLOCKED_UDP_PORTS=[23, 44, 609]
ALLOWED_TCP_PORTS=[22,53,67,68,80,443]
ALLOWED_UDP_PORTS=[]
PING_COUNT = 3
INTERVAL = "u500"


# Write to file
File.open("Outbound_Firewall_Test.txt", "w+")
$stdout.reopen("Outbound_Firewall_Test.txt", "a+")
$stderr.reopen("Outbound_Firewall_Test.txt", "a+")


# Start Tests
warn "Starting Outbound Firewall Test----------------------------------------------------------------------------- \n"

warn "  Testing Blocked TCP Ports--------------------------------------------------------------------------------------\n"

for port in BLOCKED_TCP_PORTS;
  warn"\n   Testing blocked port #{port}\n"
  system("hping #{EXTERNAL_IP} -S -s 3045 -p #{port} -c #{PING_COUNT} -i #{INTERVAL}")
end


warn "  \nTesting Blocked UDP Ports--------------------------------------------------------------------------------------\n"

for port in BLOCKED_UDP_PORTS;
  warn"\n   Testing blocked port #{port}\n"
  system("hping #{EXTERNAL_IP} --udp -s 3045 -p #{port} -c #{PING_COUNT} -i #{INTERVAL}")
end

warn "  \n Testing Allowed TCP Ports--------------------------------------------------------------------------------------\n"

for port in BLOCKED_UDP_PORTS;
  warn"\n   Testing blocked port #{port}\n"
  system("hping #{EXTERNAL_IP} --udp -s 3045 -p #{port} -c #{PING_COUNT} -i #{INTERVAL}")
end