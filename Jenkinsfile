import groovy.json.JsonSlurper;

pipeline {
    agent any
    parameters {
        // 代码仓库地址
        string(
                name: "git_code_url",
                defaultValue: "http://10.35.161.175/paas/luckysheetserver.git"
        )
        string(
                name: "harbor_url",
                defaultValue: "habor.wr.goldwind.com.cn:5000"
        )
        string(
                name: "git_ci_master_code_url",
                defaultValue: "http://10.35.161.175/jenkinsfiles/rancher-api.git"
        )
        // 存放以及拉取镜像的项目名
        string(
                name: "project_name",
                defaultValue: "paas"
        )
        // 存放以及拉取镜像的服务名
        string(
                name: "service_name",
                defaultValue: "luckysheet-server"
        )
        string(
                name: "language",
                defaultValue: "java"
        )
        string(
                name: "language_frame",
                defaultValue: "flask"
        )
        string(
                name: "build_frame",
                defaultValue: ""
        )
        // 服务所在rancher集群
        string(
                name: "rancher_cluster",
                defaultValue: "windresource"
        )
        // 服务所在rancher项目
        string(
                name: "rancher_project",
                defaultValue: "paas"
        )
        // 服务所在rancher命名空间
        string(
                name: "rancher_namespace",
                defaultValue: "savetime"
        )
        // 服务所在rancher的pod
        string(
                name: "rancher_pod",
                defaultValue: "luckysheet-server"
        )
    }

    stages {
        stage("pull code") {
            parallel {
                stage("pull code") {
                    steps {
                        dir('code') {
                            // 代码仓库所在分支
                            git branch: "master", url: "${params.git_code_url}"
                        }
                    }
                }
                stage("pull ci_master") {
                    steps {
                        dir('ci_master') {
                            git branch: "master", url: "${params.git_ci_master_code_url}"
                        }
                    }
                }
            }
        }
        stage("mvn code") {
            steps {
                dir('code') {
                    // mvn打包命令
                    sh """ source /etc/profile && mvn -Dmaven.test.skip=true clean package """
                }
            }
        }
        stage("docker build") {
            steps {
                dir('code') {
                    echo "${params.harbor_url}/${params.project_name}-${params.service_name}:${BUILD_NUMBER} ."
                    // docker镜像
                    sh """docker build -t ${params.harbor_url}/${params.project_name}/${params.project_name}-${params.service_name}:${BUILD_NUMBER} . """
                    echo "${params.harbor_url}/${params.project_name}-${params.service_name}:${BUILD_NUMBER}"
                }
            }
        }
        stage("archive code to harbor server") {
            steps {
                dir('code') {
                    sh """docker push ${params.harbor_url}/${params.project_name}/${params.project_name}-${params.service_name}:${BUILD_NUMBER} """
                }
            }
        }
        stage("deploy code server") {
            steps {
                dir('ci_master') {
                    sh """python3 rancher.py --rancher_cluster=${params.rancher_cluster} --rancher_project=${params.rancher_project}  --rancher_namespace=${params.rancher_namespace} --rancher_pod=${params.rancher_pod} --rancher_image=${params.harbor_url}/${params.project_name}/${params.project_name}-${params.service_name}:${BUILD_NUMBER}"""
                }
            }
        }
    }

    post {
        always {
            echo '构建结束...'
        }
        failure {
            echo '抱歉，构建失败！！！'
            mail subject: "'${env.JOB_NAME} [${env.BUILD_NUMBER}]' 执行失败",
                    body: """
            <div id="content">
            <h1>CI报告</h1>
            <div id="sum2">
                <h2>Jenkins 运行结果</h2>
                <ul>
             <li>jenkins的执行结果 : <a>jenkins 执行失败</a></li>
             <li>jenkins的Job名称 : <a id="url_1">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></li>
             <li>jenkins的URL : <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></li>
             <li>jenkins项目名称 : <a>${env.JOB_NAME}</a></li>
             <li>Job URL : <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></li>
             <li>构建日志：<a href="${BUILD_URL}console">${BUILD_URL}console</a></li>
                </ul>
            </div>
            </div>
            """,
            charset: 'utf-8',
            from: 'bxxxdu@163.com',
            mimeType: 'text/html',
            to: "wuzhiming@goldwind.com"
        }
        unstable {
            echo '该任务已经被标记为不稳定任务...'
        }
        changed {
            echo ''
        }
    }
}
