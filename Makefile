# $FreeBSD$

PORTNAME=	photoprism
DISTVERSION=	g20210523
CATEGORIES=	www

MAINTAINER=	huoju@devep.net
COMMENT=	Personal Photo Management powered by Go and Google TensorFlow

LICENSE=	AGPLv3

RUN_DEPENDS=  ffmpeg:multimedia/ffmpeg 
LIB_DEPENDS=	libtensorflow.so.1:science/py-tensorflow

EXTRACT_DEPENDS=  ${RUN_DEPENDS} \
	bash:shells/bash \
	bazel:devel/bazel029 \
	git:devel/git \
	gmake:devel/gmake \
	go:lang/go \
	npm:www/npm-node14 \
	wget:ftp/wget

USES= gmake

USE_GITHUB=	yes
GH_ACCOUNT=	photoprism
GH_PROJECT=	photoprism
GH_TAGNAME=     b1856b9d45502ba1a35e1d2ae6ca12fd17223895

USE_RC_SUBR=    photoprism
PHOTOPRISM_DATA_DIR=      /var/db/photoprism
SUB_LIST+=      PHOTOPRISM_DATA_DIR=${PHOTOPRISM_DATA_DIR}
SUB_FILES+=      pkg-install pkg-message

OPTIONS_SINGLE=		CPUFEATURE 
OPTIONS_SINGLE_CPUFEATURE=	NONE AVX AVX2
OPTIONS_DEFAULT = AVX
CPUFEATURE_DESC=          Enable AVX CPU extensions for Tensorflow
NONE_VARS=	BAZEL_COPT=""
AVX_VARS=	BAZEL_COPT="--copt=-march=core-avx-i --host_copt=-march=core-avx-i"
AVX2_VARS=	BAZEL_COPT="--copt=-march=core-avx2 --host_copt=-march=core-avx2"

.include <bsd.port.options.mk>

post-extract:
	@${REINPLACE_CMD} -e 's|sha1sum|shasum|g' ${WRKSRC}/scripts/download-nasnet.sh
	@${REINPLACE_CMD} -e 's|sha1sum|shasum|g' ${WRKSRC}/scripts/download-nsfw.sh

pre-build:
	@${REINPLACE_CMD} -e 's|PHOTOPRISM_VERSION=.*|PHOTOPRISM_VERSION=${GH_TAGNAME}|' ${WRKSRC}/scripts/build.sh

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/photoprism ${STAGEDIR}${PREFIX}/bin
	${MKDIR} ${STAGEDIR}${PHOTOPRISM_DATA_DIR}
	${CP} -r ${WRKSRC}/assets ${STAGEDIR}${PHOTOPRISM_DATA_DIR}/assets

pre-install:
	${MKDIR} ${STAGEDIR}${PHOTOPRISM_DATA_DIR}

.include <bsd.port.mk>
