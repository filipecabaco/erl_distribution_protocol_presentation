from pyrlang import Node, Process, GeventEngine
from pyrlang.net_kernel import NetKernel
from term import Atom
from gevent import monkey
import subprocess
import logging

monkey.patch_socket(dns=True, aggressive=True)
logging.getLogger("").setLevel(logging.DEBUG)

def remote_receiver_name():
  return Atom('orchestrator@localhost'), Atom("orchestrator")

def send_message(node, pid, msg):
  logging.info("Sending back to orchestrator")
  node.send(sender=pid,
              receiver=remote_receiver_name(),
              message=msg)

class Register(Process):
    def __init__(self, node) -> None:
      Process.__init__(self, node_name=node.node_name_)
      node.register_name(self, Atom('mailbox'))

    def handle_one_inbox_message(self, msg):
      send_message(self.get_node(), self.pid_, msg)

    def exit(self, reason=None):
      logging.error(reason)
      Process.exit(self, reason)

def main():
  e = GeventEngine()
  node = Node(node_name="registry@localhost", cookie="secret", engine=e)
  logging.debug(node)
  Register(node)
  e.run_forever()

if __name__ == "__main__":
  main()