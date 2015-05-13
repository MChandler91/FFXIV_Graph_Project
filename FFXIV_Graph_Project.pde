import processing.pdf.*;
int nodeCount;
Node[] nodes = new Node[22];
HashMap nodeTable = new HashMap();

int edgeCount;
Edge[] edges = new Edge[120];

String [] data1;
boolean record;
String output;

int yPosition;
Node selection;
color nodeColor   = #FFFFFF;
color selectColor = #FF3030;
color fixedColor  = #FF8080;
color edgeNormal   = #B2A89A;
color edgeSelected = #00E0F2;

void setup() {
  size(1600, 800);
  readFile();
}

void draw() {
  if (record) {
    beginRecord(PDF, "output.pdf");
  }
  background(29,29,33);
  fill(0);
  rect(1395, 0, 195, 800);
  fill(155);
  rect(1400, 0, 200, 800);
  smooth();  
  mouseOver();
  for (int i = 0; i < edgeCount; i++) {
    edges[i].relax();
  }
  for (int i = 0; i < nodeCount; i++) {
    nodes[i].relax();
  }
  for (int i = 0; i < nodeCount; i++) {
    nodes[i].update();
  }
  for (int i = 0; i < edgeCount; i++) {
    edges[i].draw();
  }
  for (int i = 0; i < nodeCount; i++) {
    nodes[i].draw();
  }
  if (record) {
    endRecord();
    record = false;
  }
}

Node findNode(String label) {
  label = label.toLowerCase();
  Node n = (Node) nodeTable.get(label);
  if (n == null) {
    return addNode(label);
  }
  return n;
}


Node addNode(String label) {
  label = label.toLowerCase();  
  Node n = new Node(label);  
  n.count = 75;
  if (nodeCount == nodes.length) {
    nodes = (Node[]) expand(nodes);
  }
  nodeTable.put(label, n);
  nodes[nodeCount++] = n;  
  return n;
}

void addEdge(String fromLabel, String toLabel, int value) {

  Node from = findNode(fromLabel);
  Node to = findNode(toLabel);

  Edge e = new Edge(from, to);
  e.count = value;
  if (edgeCount == edges.length) {
    edges = (Edge[]) expand(edges);
  }
  edges[edgeCount++] = e;
}

void readFile() {
  String [] lines = loadStrings("FFXIV Information.txt"); 
  data1 = split(lines[0], TAB);
  for (int i = 1; i < data1.length; i++) {
    addNode(data1[i]);
  }

  for (int j = 1; j < lines.length; j++) {
    String[] data2 = split(lines[j], TAB);
    //img = loadImage(data2[13]);
    addNode(data2[0]);
    for (int h = 1; h < data2.length; h++) {
      if (Integer.parseInt(data2[h]) != 0) {
        addEdge(data1[h], data2[0], Integer.parseInt(data2[h]));
      }
    }
  }
}

void keyPressed() {
  if(key == 'r' || key == 'R'){
    record = true;
  }
}
void mousePressed() {
  // Ignore anything greater than this distance
  float closest = 20;
  for (int i = 0; i < nodeCount; i++) {
    Node n = nodes[i];
    float d = dist(mouseX, mouseY, n.x, n.y);
    if (d < closest) {
      selection = n;
      closest = d;
    }
  }
  if (selection != null) {
    if (mouseButton == LEFT) {
      selection.fixed = true;
    } else if (mouseButton == RIGHT) {
      selection.fixed = false;
    }
  }
}

void mouseDragged() {
  if (selection != null) {
    selection.x = mouseX;
    selection.y = mouseY;
  }
}

void mouseOver() {
  yPosition = 15;
  float closest = 20;
  for (int i = 0; i < nodeCount; i++) {
    Node n = nodes[i];
    float d = dist(mouseX, mouseY, n.x, n.y);
    if (d < closest) {
      for (int j = 0; j < edges.length; j++) {
        if (edges[j] != null) {
          if (edges[j].to.label == n.label || edges[j].from.label == n.label) {
            edges[j].edgeColor = edgeSelected;
            fill(0);
            textSize(12);
            output = edges[j].to.label + " " + edges[j].from.label + " " + edges[j].count;
            yPosition = yPosition + 60;
            text(output, 1500, yPosition);
          } else {
            edges[j].edgeColor = edgeNormal;
          }
          selection = n;
          closest = d;
        }
      }
    }
  }
}

