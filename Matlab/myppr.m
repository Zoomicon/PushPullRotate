function docNode=myppr(DH)
    M01=metas(DH(1,1),DH(1,2),DH(1,3),DH(1,4));
    M12=metas(DH(2,1),DH(2,2),DH(2,3),DH(2,4));
    M23=metas(DH(3,1),DH(3,2),DH(3,3),DH(3,4));
    M34=metas(DH(4,1),DH(4,2),DH(4,3),DH(4,4));
    M45=metas(DH(5,1),DH(5,2),DH(5,3),DH(5,4));
    M56=metas(DH(6,1),DH(6,2),DH(6,3),DH(6,4));
    M67=metas(DH(7,1),DH(7,2),DH(7,3),DH(7,4));
    M78=metas(DH(8,1),DH(8,2),DH(8,3),DH(8,4));
    M89=metas(DH(9,1),DH(9,2),DH(9,3),DH(9,4));
    M910=metas(DH(10,1),DH(10,2),DH(10,3),DH(10,4));
    M1011=metas(DH(11,1),DH(11,2),DH(11,3),DH(11,4));
    M1112=metas(DH(12,1),DH(12,2),DH(12,3),DH(12,4));
    M1213=metas(DH(13,1),DH(13,2),DH(13,3),DH(13,4));
    M1314=metas(DH(14,1),DH(14,2),DH(14,3),DH(14,4));
    M1415=metas(DH(15,1),DH(15,2),DH(15,3),DH(15,4));
    
    %M78=[1 0 0 l7;0 1 0 0;0 0 1 0;0 0 0 1];
    
    M02=M01*M12;
    M03=M02*M23;
    M04=M03*M34;
    M05=M04*M45;
    M06=M05*M56;
    M07=M06*M67;
    M08=M07*M78;
    M09=M08*M89;
    M010=M09*M910;
    M011=M010*M1011;
    M012=M011*M1112;
    M013=M012*M1213;
    M014=M013*M1314;
    M015=M014*M1415;
      
    docNode = com.mathworks.xml.XMLUtils.createDocument('PPR');
   
    counter_con=1;
    counter_rod=1;
    for i=1:3:15
    connector = docNode.createElement('connector');
    docNode.getDocumentElement.appendChild(connector);
    xmlwrite(docNode)
    connector.setAttribute('x',char(eval(['M0' num2str(i) '(1,4)'])));
    connector.setAttribute('y',char(eval(['M0' num2str(i) '(2,4)'])));
    connector.setAttribute('z',char(eval(['M0' num2str(i) '(3,4)'])));
    connector.setAttribute('name',char(['connector' num2str(counter_con)]));
    connector.setAttribute('hasChild',char(['connector' num2str(counter_con+1)]));
    counter_con=counter_con+1;
    %xmlwrite(docNode);
    connector = docNode.createElement('connector');
    docNode.getDocumentElement.appendChild(connector);
    
    connector.setAttribute('x',char(eval(['M0' num2str(i+1) '(1,4)'])));
    connector.setAttribute('y',char(eval(['M0' num2str(i+1) '(2,4)'])));
    connector.setAttribute('z',char(eval(['M0' num2str(i+1) '(3,4)'])));
    connector.setAttribute('name',char(['connector' num2str(counter_con)]));
    connector.setAttribute('hasChild',char(['rod' num2str(counter_rod)]));
    counter_con=counter_con+1;
    %xmlwrite(docNode);
    rod = docNode.createElement('rod');
    docNode.getDocumentElement.appendChild(rod);
    %xmlwrite(docNode);
    rod.setAttribute('name',char(['rod' num2str(counter_rod)]));
    rod.setAttribute('minlen','');
    rod.setAttribute('maxlen','');
    if i<13
    rod.setAttribute('hasChild',char(['connector' num2str(counter_con)]));
    else
    rod.setAttribute('hasChild','');
    end
    counter_rod=counter_rod+1;
    
    
    xmlwrite(docNode);
    end