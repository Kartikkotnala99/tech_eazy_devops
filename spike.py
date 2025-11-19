"""
Spike Generator Script
----------------------
This script publishes fake CPU or Memory metrics to CloudWatch so that
Auto Scaling scaling policies get triggered.

Usage:
    python spike_publish_metric.py --metric CPUUtilization --value 95
    python spike_publish_metric.py --metric MemoryUtilization --value 80
"""

import argparse
import time
import boto3


def publish_metric(namespace, metric_name, value, dimensions, region):
    cw = boto3.client('cloudwatch', region_name=region)

    response = cw.put_metric_data(
        Namespace=namespace,
        MetricData=[
            {
                'MetricName': metric_name,
                'Dimensions': dimensions,
                'Timestamp': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
                'Value': value,
                'Unit': 'Percent'
            }
        ]
    )
    return response


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('--namespace', default='Custom/ASG')
    parser.add_argument('--metric', required=True,
                        help='CPUUtilization or MemoryUtilization')
    parser.add_argument('--value', type=float, required=True,
                        help='Metric value (e.g., 90)')
    parser.add_argument('--region', default='ap-south-1')

    parser.add_argument('--dimensions', nargs='*',
                        help='e.g. AutoScalingGroupName=app-asg')

    args = parser.parse_args()

    dims = []
    if args.dimensions:
        for d in args.dimensions:
            name, val = d.split('=', 1)
            dims.append({'Name': name, 'Value': val})

    print(f"Publishing metric {args.metric}={args.value}% to {args.namespace}")

    resp = publish_metric(args.namespace, args.metric, args.value, dims, args.region)

    print("Response:", resp)

