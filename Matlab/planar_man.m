clear
clc

q1 = sym('q1','real');
d2 = sym('d2','real');
q3 = sym('q3','real');
d4 = sym('d4','real');
q5 = sym('q5','real');
d6 = sym('d6','real');
q7 = sym('q7','real');
l7 = sym('l7','real');

DH=[0 0 0 q1;
    pi/2 0 d2 0;
    -pi/2 0 0 q3;
    pi/2 0 d4 0;
    -pi/2 0 0 q5;
    pi/2 0 d6 0
    -pi/2 0 0 q7-pi/2];

    M01=metas(DH(1,1),DH(1,2),DH(1,3),DH(1,4));
    M12=metas(DH(2,1),DH(2,2),DH(2,3),DH(2,4));
    M23=metas(DH(3,1),DH(3,2),DH(3,3),DH(3,4));
    M34=metas(DH(4,1),DH(4,2),DH(4,3),DH(4,4));
    M45=metas(DH(5,1),DH(5,2),DH(5,3),DH(5,4));
    M56=metas(DH(6,1),DH(6,2),DH(6,3),DH(6,4));
    M67=metas(DH(7,1),DH(7,2),DH(7,3),DH(7,4));
    M78=[1 0 0 l7;0 1 0 0;0 0 1 0;0 0 0 1];
    
    M02=M01*M12;
    M03=M02*M23;
    M04=M03*M34;
    M05=M04*M45;
    M06=M05*M56;
    M07=M06*M67;
    M08=M07*M78;
    
    i=1;
    docNode = com.mathworks.xml.XMLUtils.createDocument('planar_robot');
    connector = docNode.createElement('connector');
    docNode.getDocumentElement.appendChild(connector);
    xmlwrite(docNode)
    connector.setAttribute('x',char(eval(['M0' num2str(i) '(1,4)'])))
    connector.setAttribute('y',char(eval(['M0' num2str(i) '(2,4)'])))
    connector.setAttribute('z','0')
    connector.setAttribute('name','connector1')
    connector.setAttribute('hasChild','rod1')
   % x = docNode.createElement('x');
   % x1 = docNode.createTextNode(char(eval(['M0' num2str(i) '(1,4)'])))
   % x.appendChild(x1)
   % connector.appendChild(x)
    xmlwrite(docNode)
    %y= docNode.createElement('y');
    %y1 = docNode.createTextNode(char(eval(['M0' num2str(i) '(2,4)'])))
    %y.appendChild(y1)
    %connector.appendChild(y)
    
    xmlwrite(docNode)
    rod = docNode.createElement('rod');
    docNode.getDocumentElement.appendChild(rod)
    rod.setAttribute('minlen','')
    rod.setAttribute('maxlen','')
    rod.setAttribute('name','rod1')
    rod.setAttribute('hasChild','connector2')
   
    %minlen = docNode.createElement('minlen');
    %rod.appendChild(minlen)
    %maxlen = docNode.createElement('maxlen');
    %rod.appendChild(maxlen)
    xmlwrite(docNode)
    counter=2;
for i=3:2:8
    connector = docNode.createElement('connector');
    docNode.getDocumentElement.appendChild(connector);
    xmlwrite(docNode)
    connector.setAttribute('x',char(eval(['M0' num2str(i) '(1,4)'])))
    connector.setAttribute('y',char(eval(['M0' num2str(i) '(2,4)'])))
    connector.setAttribute('z','0')
    connector.setAttribute('name',['connector' num2str(counter)])
    connector.setAttribute('hasChild',['rod' num2str(counter)])
    xmlwrite(docNode)
    rod = docNode.createElement('rod');
    docNode.getDocumentElement.appendChild(rod)
    rod.setAttribute('minlen','')
    rod.setAttribute('maxlen','')
   rod.setAttribute('name',['rod' num2str(counter)])
   if i<7
   rod.setAttribute('hasChild',['connector' num2str(counter+1)])
   else
       rod.setAttribute('hasChild','')
   end
    xmlwrite(docNode)
    counter=counter+1;
end 

    
    
    
    
    %connector.setAttribute('x');%M01(1,4));
    %connector.setAttribute('y',M01(2,4));
    %rod = docNode.createElement('rod');
    
    
    
    
    
    
    
    
    
    