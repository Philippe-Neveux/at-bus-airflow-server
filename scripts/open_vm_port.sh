gcloud compute firewall-rules create allow-8080 \
  --allow=tcp:8080 \
  --network=default \
  --source-ranges=0.0.0.0/0