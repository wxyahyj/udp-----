#!/usr/bin/env python3
"""Setup script for UDP Streamer package"""

from setuptools import setup, find_packages
from pathlib import Path

# Read README
readme_file = Path(__file__).parent / "README.md"
long_description = readme_file.read_text(encoding="utf-8") if readme_file.exists() else ""

setup(
    name="udp-streamer",
    version="1.0.0",
    description="High-performance UDP streaming sender - similar to OBS streaming",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Your Name",
    author_email="your.email@example.com",
    url="https://github.com/yourusername/udp推流发射器",
    license="MIT",
    
    py_modules=["udp_streamer"],
    
    python_requires=">=3.8",
    install_requires=[
        "opencv-python>=4.5.0",
        "numpy>=1.19.0",
        "mss>=9.0.0",
    ],
    
    entry_points={
        "console_scripts": [
            "udp-streamer=udp_streamer:main",
        ],
    },
    
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Multimedia :: Video",
        "Topic :: System :: Networking",
    ],
    
    keywords="streaming udp video ffmpeg encoder screen-capture",
    
    project_urls={
        "Bug Reports": "https://github.com/yourusername/udp推流发射器/issues",
        "Source": "https://github.com/yourusername/udp推流发射器",
        "Documentation": "https://github.com/yourusername/udp推流发射器#readme",
    },
)
