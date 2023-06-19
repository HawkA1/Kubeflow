#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM apache/spark-py
WORKDIR /

# Reset to root to run installation tasks
USER 0
ARG spark_uid=185
#Set permissions in dockerfile
RUN chmod g+s /opt/spark/work-dir
WORKDIR /opt/spark/work-dir
RUN chmod 777 /opt/spark/work-dir
RUN chown ${spark_uid}:${spark_uid} /opt/spark/work-dir
WORKDIR /opt/spark/work-dir
ENTRYPOINT [ "/opt/entrypoint.sh" ]

# Specify the User that the actual main process will run as
USER ${spark_uid}
