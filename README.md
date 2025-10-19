# 24-365-demo

가상화폐거래소 인프라 환경 구성해보기 

만년 걸릴거같아


-/-//

1.	ArgoCD 순서ㅓ controller 앱들에 sync-wave가 -2/-1, CR들(IngressClass/Ingress/ServiceMonitor 등)이 0 이상인지. 화긴

	2.	Ingress namepace prod-exchange 안의 exchange-alb가 exchange-gw(동일 ns로)로 백엔드 지정돼 있는지.  ￼
	3.	prod 라벨: prod-* ns 리소스 전부에 app.kubernetes.io/managed-by: argocd가 있는지.
	4.	NetPol egress: 온프레 RPC/MSK로 ipBlock로 좁혀져 있는지(Endpoints를 podSelector로 잡지 않았는지).
