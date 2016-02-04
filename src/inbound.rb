#User Configuration Section
TARGET_IP="192.168.1.30"
INTERNAL_IP="192.168.5.3"
BLOCKED_TCP_PORTS=[111,115,137,138,139,32768,32769,32770,32771,32772,32773,32774,32775,23]
BLOCKED_UDP_PORTS=[137,138,139,32768,32769,32770,32771,32772,32773,32774,32775]
ALLOWED_TCP_PORTS=[22,53,67,68,80,443]
ALLOWED_UDP_PORTS=[53,67,80,443,9900,5656]
PING_COUNT = 3
INTERVAL = "u500"


# Write to file
File.open("Inbound_Firewall_Test.txt", "w+")
$stdout.reopen("Inbound_Firewall_Test.txt", "a+")
$stderr.reopen("Inbound_Firewall_Test.txt", "a+")


# Start Tests
warn "Starting Inbound Firewall Test----------------------------------------------------------------------------- \n"

warn "  Testing Blocked TCP Ports--------------------------------------------------------------------------------------\n"

for port in BLOCKED_TCP_PORTS;
  warn"\n   Testing blocked port #{port}\n"
  system("hping #{TARGET_IP} -S -s 80 -p #{port} -c #{PING_COUNT} -i #{INTERVAL}")
end


warn "  \nTesting Blocked UDP Ports--------------------------------------------------------------------------------------\n"

for port in BLOCKED_UDP_PORTS;
  warn"\n   Testing blocked port #{port}\n"
  system("hping #{TARGET_IP} --udp -s 80 -p #{port} -c #{PING_COUNT} -i #{INTERVAL}")
end

# Do  not  accept  any  packets  with  a  source  address  from  the  outside  matching  your internal network.

warn "  \nTesting for lan source spoofing--------------------------------------------------------------------------------------\n"

  system("hping #{TARGET_IP} -a #{INTERNAL_IP} -s 80 -S -p 80 -c #{PING_COUNT} -i #{INTERVAL}")


# #You must ensure the you reject those connections that are coming the “wrong” way (i.e., inbound SYN packets to high ports).
warn "  \nTesting for SYN Packets with High Ports-------------------------------------------------------------------\n"
  system("hping #{TARGET_IP} -s 80  -S -p 2222 -c #{PING_COUNT} -i #{INTERVAL}")

#Drop all TCP packets with the SYN and FIN bit set.
warn "  \nTesting for SYN and FIN-------------------------------------------------------------------\n"
  system("hping #{TARGET_IP} -S -F -s 80  -p 80 -c #{PING_COUNT} -i #{INTERVAL}")







# warn "  \n Testing Allowed TCP Ports--------------------------------------------------------------------------------------\n"
#
# for port in ALLOWED_TCP_PORTS;
#   warn"\n   Testing allowed port #{port}\n"
#   system("hping #{TARGET_IP}  -S -s 80 -p #{port} -c #{PING_COUNT} -i #{INTERVAL}")
# end
#
# warn "  \nTesting Allowed UDP Ports--------------------------------------------------------------------------------------\n"
#
# for port in ALLOWED_UDP_PORTS;
#   warn"\n   Testing allowed port #{port}\n"
#   system("hping #{TARGET_IP} --udp -s 80 -p #{port} -c #{PING_COUNT} -i #{INTERVAL}")
# end
#
