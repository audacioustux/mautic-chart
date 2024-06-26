import http from "k6/http";
import { sleep } from "k6";

export const options = {
  discardResponseBodies: true,
  scenarios: {
    ssr: {
      executor: "ramping-vus",
      startVUs: 0,
      stages: [
        { duration: "10m", target: 5000 },
      ],
      gracefulRampDown: "0s",
    },
  },
  thresholds: {
    http_req_waiting: [{ threshold: "p(90)<15000", abortOnFail: true }],
    http_req_failed: [{ threshold: "rate<0.05", abortOnFail: true }],
  },
};

export default async function main() {
  http.get("https://mt.coderstrust.global/test");
  sleep(30);
}
