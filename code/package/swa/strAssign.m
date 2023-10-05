function in1=strAssign(in1,r1,r2,rhs)
 if isempty(r1),  r1=1;  end %beginning index of in1
 if isempty(r2),  r2=length(in1);  end %ending index of in1
 rhsL=length(rhs);   lhsL=r2-r1+1;
 % rhs is too long for the left
 if lhsL<rhsL,  in1(r1:r2)=rhs(1:lhsL);  end
 % sizes match
 if lhsL==rhsL,  in1(r1:r2)=rhs;  end
 % rhs is too short for the left
 if lhsL>rhsL,  in1(r1:r1+rhsL-1)=rhs;,  in1(r1+rhsL:lhsL)=' ';  end
end %function