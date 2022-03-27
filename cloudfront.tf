# ----------------------------------------
# CloudFront cache distribution
# ----------------------------------------
resource "aws_cloudfront_distribution" "cf" {
    # 有効化どうか
    enabled = true

    # IPv6通信を有効にするか
    is_ipv6_enabled = true

    # コメント
    comment = "cache distribution"

    # CDNをどの国のエッジロケーションで利用できるようにするかを選択
    price_class = "PriceClass_All"

    origin {
        # DNSドメイン名
        domain_name = aws_route53_record.route53_record.fqdn

        # オリジンを識別するユニークな名前
        origin_id = aws_lb.alb.name

        # 独自オリジン
        custom_origin_config {
            # "http-only", "https-only", "atch-viewer"のいずれかを記入
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = [ "TLSv1", "TLSv1.1", "TLSv1.2" ]
            http_port = 80
            https_port = 443
        }
    }

    default_cache_behavior {
        # 許可するメソッド
        allowed_methods = [ "GET", "HEAD" ]

        # キャッシュするメソッド
        cached_methods = [ "GET", "HEAD" ]

        forwarded_values {
            query_string = true
            cookies {
                forward = "all"
            }
        }

        # 転送先のオリジンID
        target_origin_id = aws_lb.alb.name

        # "allow-all", "https-only", "redirect-to-https"のいずれかを記入
        viewer_protocol_policy = "redirect-to-https"

        # 最小キャッシュ時間（秒）
        min_ttl = 0
        
        # デフォルトキャッシュ時間（秒）
        default_ttl = 0

        # 最大キャッシュ時間（秒）
        max_ttl = 0
    }

    # アクセス制限
    restrictions {
        # どこの国からアクセスを許可するのかという、ロケーションによる制限
        geo_restriction {
            restriction_type = "none"
        }
    }

    # ドメイン名設定
    aliases = [ "dev.${var.domain}" ]

    # 証明書
    viewer_certificate {
        # ACM証明書のARN
        acm_certificate_arn = aws_acm_certificate.virginia_cert.arn
        minimum_protocol_version = "TLSv1.2_2019"

        # ”sni-only”にすることで一台のサーバーで複数の証明書が利用できるという設定
        ssl_support_method = "sni-only"
    }
}

resource "aws_route53_record" "route53_cloudfront" {
    zone_id = aws_route53_zone.route53_zone.id
    name = "dev.${var.domain}"
    type = "A"

    alias {
        name = aws_cloudfront_distribution.cf.domain_name
        zone_id = aws_cloudfront_distribution.cf.hosted_zone_id
        evaluate_target_health = true
    }
}
